#!/bin/bash

# 환경 설정
JBOSS_CLI="/rpwas/eap/domains/server11/bin/jboss-cli.sh"
JBOSS_USER="admin"
JBOSS_PASS="rpjboss1!"
JBOSS_HOST="192.168.56.21"
JBOSS_PORT="9990"
CONTROLLER="$JBOSS_HOST:$JBOSS_PORT"

# 점검 대상 WAR 이름
DEPLOYMENT="simple.war"

# 임시파일
TMP_HEAP="/tmp/heap.tmp"
TMP_DS_LIST="/tmp/ds-list.tmp"
TMP_DS="/tmp/ds.tmp"
TMP_GC_Y="/tmp/gc-young.tmp"
TMP_GC_F="/tmp/gc-full.tmp"
TMP_THREAD="/tmp/thread.tmp"

echo "🧠 ===== CPU LOAD ====="
CPU_COUNT=$(nproc)
CPU_LOAD=$(uptime | awk -F 'load average:' '{print $2}' | cut -d',' -f1 | xargs)
CPU_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($CPU_LOAD / $CPU_COUNT) * 100}")
echo "CPU Cores   : $CPU_COUNT"
echo "Load Avg 1m : $CPU_LOAD"
echo "Est. Usage  : $CPU_PERCENT %"
echo

echo "💽 ===== DISK USAGE ( / ) ====="
df -h / | awk 'NR==2 {print "Total:", $2, "| Used:", $3, "| Avail:", $4, "| Usage:", $5}'
echo

echo "🧵 ===== THREAD POOL (IO/Worker) ====="
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_THREAD
/subsystem=io/worker=default:read-resource(include-runtime=true)
/subsystem=undertow:read-resource(include-runtime=true, recursive=true)
quit
EOF

IO_THREADS=$(grep '"io-threads"' $TMP_THREAD | awk '{print $3}' | tr -d '",')
MAX_THREADS=$(grep '"task-max-threads"' $TMP_THREAD | awk '{print $3}' | tr -d '",')
echo "IO Threads        : $IO_THREADS"
echo "Task Max Threads  : $MAX_THREADS"
echo

echo "🗃️  ===== DATASOURCE POOL STATUS (ALL) ====="

# 1. 정확한 datasource 목록 추출
$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_DS_LIST
/subsystem=datasources:read-children-names(child-type=data-source)
quit
EOF

# 2. 실제 datasource 이름만 추출 (불필요한 필드 제외)
grep -A 10 '"result" => \[' $TMP_DS_LIST | grep -v 'outcome' | grep -v '=>' | grep -v 'result' | grep -oP '"\K[^"]+(?=")' | while read DSNAME; do
  echo "▶️ Datasource: $DSNAME"

  # 3. 개별 datasource 통계 조회
  $JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_DS
/subsystem=datasources/data-source=$DSNAME/statistics=pool:read-resource(include-runtime=true)
quit
EOF

  # 4. 통계 값 파싱
  ACTIVE=$(grep '"ActiveCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  AVAILABLE=$(grep '"AvailableCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  MAXUSED=$(grep '"MaxUsedCount"' $TMP_DS | awk '{print $3}' | tr -d '",')
  TIMEOUT=$(grep '"TimedOut"' $TMP_DS | awk '{print $3}' | tr -d '",')

  if [[ -z "$ACTIVE" && -z "$AVAILABLE" && -z "$MAXUSED" ]]; then
    echo "   ⛔ 통계 정보 없음 (statistics 비활성 또는 연결 이력 없음)"
  else
    echo "   - Active     : $ACTIVE"
    echo "   - Available  : $AVAILABLE"
    echo "   - Max Used   : $MAXUSED"
    echo "   - Timed Out  : $TIMEOUT"
  fi
done

echo "📊 ===== JAVA HEAP MEMORY USAGE ====="

$JBOSS_CLI --connect --controller=$CONTROLLER --user=$JBOSS_USER --password=$JBOSS_PASS <<EOF > $TMP_HEAP
/core-service=platform-mbean/type=memory:read-resource(include-runtime=true)
quit
EOF

# 1. heap-memory-usage 블록 내에서 used/max 값만 추출
USED=$(awk '/heap-memory-usage/ {flag=1; next} /}/ {flag=0} flag && /used/ {print $3}' "$TMP_HEAP" | head -n1 | tr -d '",L')
MAX=$(awk '/heap-memory-usage/ {flag=1; next} /}/ {flag=0} flag && /max/ {print $3}' "$TMP_HEAP" | head -n1 | tr -d '",L')

# 2. 공백 제거
USED=$(echo "$USED" | xargs)
MAX=$(echo "$MAX" | xargs)

# 3. 유효성 검사 및 계산
if [[ "$USED" =~ ^[0-9]+$ ]] && [[ "$MAX" =~ ^[0-9]+$ ]] && [[ "$MAX" -ne 0 ]]; then
  USED_GB=$(awk "BEGIN {printf \"%.2f\", $USED / 1073741824}")
  MAX_GB=$(awk "BEGIN {printf \"%.2f\", $MAX / 1073741824}")
  PERCENT=$(awk "BEGIN {printf \"%.1f\", ($USED / $MAX) * 100}")
  echo "Used Heap: $USED_GB GB"
  echo "Max Heap : $MAX_GB GB"
  echo "Usage    : $PERCENT %"
else
  echo "Heap memory 정보가 부족하거나 JVM에서 제공하지 않습니다."
fi


echo "♻️ ===== GARBAGE COLLECTION ====="
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

echo "Young GC (PS Scavenge) : ${YOUNG_COUNT:-0} times / ${YOUNG_TIME:-0} ms"
echo "Full  GC (PS MarkSweep): ${FULL_COUNT:-0} times / ${FULL_TIME:-0} ms"
echo

# 정리
rm -f $TMP_HEAP $TMP_DS_LIST $TMP_DS $TMP_GC_Y $TMP_GC_F $TMP_THREAD

