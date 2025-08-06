#!/bin/bash

# [1] 로그 파일 경로 설정
LOG_DIR="/rpwas/eap/domains/server11/logs"
LOG_FILE="$LOG_DIR/server.log"

# [2] 현재 월 기준 필터 (예: 2025-08)
CHECK_MONTH=$(date "+%Y-%m")
echo "======================="
echo "JBoss EAP 7.4 Log 점검"
echo "======================="
echo "점검 기준 월: $CHECK_MONTH"
echo "로그 파일 경로: $LOG_FILE"
echo

# [3] ERROR 로그 수 (이번 달)
echo "[1] ERROR 로그 수 (이번 달)"
grep "ERROR" "$LOG_FILE" | grep "$CHECK_MONTH" | wc -l
echo

# [4] WARN 로그 수 (이번 달)
echo "[2] WARN 로그 수 (이번 달)"
grep "WARN" "$LOG_FILE" | grep "$CHECK_MONTH" | wc -l
echo

# [5] Full GC 로그 (이번 달)
echo "[3] Full GC 로그 (이번 달)"
grep "Full GC" "$LOG_FILE" | grep "$CHECK_MONTH" | tail -n 5
echo

# [6] OutOfMemoryError (이번 달)
echo "[4] OutOfMemoryError 발생 여부 (이번 달)"
grep -i "OutOfMemoryError" "$LOG_FILE" | grep "$CHECK_MONTH"
echo

# [7] Datasource 연결 실패 (이번 달)
echo "[5] Datasource 연결 실패 (이번 달)"
grep -i "javax.resource.ResourceException" "$LOG_FILE" | grep "$CHECK_MONTH"
grep -i "Could not create connection" "$LOG_FILE" | grep "$CHECK_MONTH"
echo

# [8] 배포 실패 로그 (이번 달)
echo "[6] 배포 실패 로그 (이번 달)"
grep -i "deployment" "$LOG_FILE" | grep -i "failed" | grep "$CHECK_MONTH"
echo

# [9] 서비스 중단 또는 접속불가 로그 (이번 달)
echo "[7] 서비스 중단/접속불가 관련 로그 (이번 달)"
grep -i "exception" "$LOG_FILE" | grep "$CHECK_MONTH" | grep -i -E "connect|connection|bind|unreachable|refused"
echo

# [10] 최근 로그 미리보기
echo "[8] 최근 로그 10줄 미리보기"
tail -n 10 "$LOG_FILE"
echo

