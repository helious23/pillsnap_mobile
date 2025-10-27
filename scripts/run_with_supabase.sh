#!/bin/bash

# PillSnap Flutter 실행 스크립트 (API + Supabase)
# 사용법: ./scripts/run_with_supabase.sh

echo "🚀 PillSnap 실행"
echo "================================"

# .env 파일에서 환경변수 로드
if [ -f .env ]; then
  echo "📋 .env 파일 로드 중..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "❌ .env 파일을 찾을 수 없습니다!"
  echo "   .env 파일을 생성하고 필요한 키를 추가하세요:"
  echo "   API_URL=https://api.pillsnap.co.kr"
  echo "   API_KEY=your_api_key"
  echo "   SUPABASE_PROJECT_URL=your_supabase_url"
  echo "   SUPABASE_ANON_KEY=your_supabase_anon_key"
  exit 1
fi

# Flutter 실행 (--dart-define으로 환경변수 주입)
flutter run \
  --dart-define=API_URL=$API_URL \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=SUPABASE_URL=$SUPABASE_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=DEBUG=true

echo "✅ 앱 종료됨"
