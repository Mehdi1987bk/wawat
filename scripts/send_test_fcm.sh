#!/bin/bash
# Отправка тестового FCM через HTTP v1 API (Legacy API больше не работает).
# Нужен OAuth2-токен: проще всего через gcloud (см. ниже).
#
# Использование:
#   ./scripts/send_test_fcm.sh "FCM_REGISTRATION_TOKEN"
#   (предварительно: gcloud auth application-default login)

PROJECT_ID="wawatair-b212f"
TOKEN="${1:?Usage: $0 <FCM_REGISTRATION_TOKEN>}"

# Получить access token через gcloud (Application Default Credentials)
if ! command -v gcloud &>/dev/null; then
  echo "Need gcloud CLI. Install: https://cloud.google.com/sdk/docs/install"
  echo "Then run: gcloud auth application-default login"
  exit 1
fi

ACCESS_TOKEN=$(gcloud auth application-default print-access-token 2>/dev/null)
if [ -z "$ACCESS_TOKEN" ]; then
  echo "Run once: gcloud auth application-default login"
  echo "Pick the Google account that has access to Firebase project: $PROJECT_ID"
  exit 1
fi

echo "Sending test notification (FCM v1)..."
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\":{\"token\":\"$TOKEN\",\"notification\":{\"title\":\"Test\",\"body\":\"Тестовое уведомление\"}}}" \
  "https://fcm.googleapis.com/v1/projects/$PROJECT_ID/messages:send"
echo ""
