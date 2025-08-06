#!/bin/bash

# 환경 설정
JBOSS_CLI="/rpwas/eap/domains/server11/bin/jboss-cli.sh"
JBOSS_USER="admin"
JBOSS_PASS="rpjboss1!"
JBOSS_HOST="192.168.56.21"
JBOSS_PORT="9990"
CONTROLLER="$JBOSS_HOST:$JBOSS_PORT"

# 임시파일 경로
TMP_HEAP="/tmp/heap.tmp"
TMP_DS_LIST="/tmp/ds-list.tmp"
TMP_DS="/tmp/ds.tmp"
TMP_GC_Y="/tmp/gc-young.tmp"
TMP_GC_F="/tmp/gc-full.tmp"
TMP_THREAD="/tmp/thread.tmp"

echo "🧠 [CPU 사용률 점검]"
CPU_COUNT=$(nproc)
CPU_LOAD=$(uptime | awk -F 'load average:' '{print $2}' | cut -d',' -f1 | xargs)
CPU_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($CPU_LOAD / $CPU_COUNT) * 100}")
echo "- CPU 코어 수: $CPU_COUNT개"
echo "- 1분 평균 부하: $CPU_LOAD"
echo "- 예상 CPU 사용률: $CPU_PERCENT %"
echo

echo "💽 [디스크 사용량 점검] (/ 기준)"
df -h / | awk 'NR==2 {printf("- 총 용량: %s | 사용 중: %s | 사용 가능: %s | 사용률: %s\n", $2, $3, $4, $5)}'
echo

echo "🧵 [쓰레드 풀(Thread Pool) 상태]"
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_THREAD
/subsystem=io/worker=default:read-resource(include-runtime=true)
/subsystem=undertow:read-resource(include-runtime=true, recursive=true)
quit
EOF

IO_THREADS=$(grep '"io-threads"' $TMP_THREAD | awk '{print $3}' | tr -d '",')
MAX_THREADS=$(grep '"task-max-threads"' $TMP_THREAD | awk '{print $3}' | tr -d '",')
echo "- IO 쓰레드 수         : $IO_THREADS"
echo "- 작업 최대 쓰레드 수  : $MAX_THREADS"
echo

echo "🗃️ [데이터소스 커넥션 풀 상태]"
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_DS_LIST
/subsystem=datasources:read-children-names(child-type=data-source)
quit
EOF

grep -A 10 '"result" => \[' $TMP_DS_LIST | grep -v 'outcome' | grep -v '=>' | grep -v 'result' | grep -oP '"\K[^"]+(?=")' | while read DSNAME; do
  echo "▶️ 데이터소스: $DSNAME"

  $JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_DS
/subsystem=datasources/data-source=$DSNAME/statistics=pool:read-resource(include-runtime=true)
quit
EOF

  ACTIVE=$(grep '"ActiveCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  AVAILABLE=$(grep '"AvailableCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  MAXUSED=$(grep '"MaxUsedCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  TIMEOUT=$(grep '"TimedOut"' $TMP_DS | awk '{print $3}' | tr -d '",')

  if [[ -z "$ACTIVE" && -z "$AVAILABLE" && -z "$MAXUSED" ]]; then
    echo "   ⛔ 통계 정보 없음 (statistics 비활성 또는 연결 이력 없음)"
  else
    echo "   - 활성 커넥션 수      : $ACTIVE"
    echo "   - 사용 가능한 커넥션  : $AVAILABLE"
    echo "   - 최대 사용 커넥션 수 : $MAXUSED"
    echo "   - 커넥션 타임아웃 수  : $TIMEOUT"
  fi
done
echo

echo "📊 [Java Heap 메모리 사용 현황]"
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_HEAP
/core-service=platform-mbean/type=memory:read-resource(include-runtime=true)
quit
EOF

USED=$(awk '/heap-memory-usage/ {flag=1; next} /}/ {flag=0} flag && /used/ {print $3}' "$TMP_HEAP" | head -n1 | tr -d '",L')
MAX=$(awk '/heap-memory-usage/ {flag=1; next} /}/ {flag=0} flag && /max/ {print $3}' "$TMP_HEAP" | head -n1 | tr -d '",L')

USED=$(echo "$USED" | xargs)
MAX=$(echo "$MAX" | xargs)

if [[ "$USED" =~ ^[0-9]+$ ]] && [[ "$MAX" =~ ^[0-9]+$ ]] && [[ "$MAX" -ne 0 ]]; then
  USED_GB=$(awk "BEGIN {printf \"%.2f\", $USED / 1073741824}")
  MAX_GB=$(awk "BEGIN {printf \"%.2f\", $MAX / 1073741824}")
  PERCENT=$(awk "BEGIN {printf \"%.1f\", ($USED / $MAX) * 100}")
  echo "- 현재 사용량: $USED_GB GB"
  echo "- 최대 허용량: $MAX_GB GB"
  echo "- 사용률: $PERCENT %"
else
  echo "⚠️ Heap memory 정보가 부족하거나 JVM에서 제공하지 않습니다."
fi
echo

echo "♻️ [Garbage Collection(GC) 상태]"
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_GC_Y
/core-service=platform-mbean/type=garbage-collector/name="PS Scavenge":read-resource(include-runtime=true)
quit
EOF

$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_GC_F
/core-service=platform-mbean/type=garbage-collector/name="PS MarkSweep":read-resource(include-runtime=true)
quit
EOF

YOUNG_COUNT=$(grep '"collection-count"' $TMP_GC_Y | awk '{print $3}' | tr -d '",L')
YOUNG_TIME=$(grep '"collection-time"' $TMP_GC_Y | awk '{print $3}' | tr -d '",L')
FULL_COUNT=$(grep '"collection-count"' $TMP_GC_F | awk '{print $3}' | tr -d '",L')
FULL_TIME=$(grep '"collection-time"' $TMP_GC_F | awk '{print $3}' | tr -d '",L')

echo "- Young GC (PS Scavenge) : ${YOUNG_COUNT:-0}회 / ${YOUNG_TIME:-0}ms"
echo "- Full  GC (PS MarkSweep) : ${FULL_COUNT:-0}회 / ${FULL_TIME:-0}ms"
echo

# 임시 파일 삭제
rm -f $TMP_HEAP $TMP_DS_LIST $TMP_DS $TMP_GC_Y $TMP_GC_F $TMP_THREAD

