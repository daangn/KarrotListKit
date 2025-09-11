#!/bin/bash

# 매크로 테스트만 실행하는 스크립트
echo "🔧 Running KarrotListKit Macro Tests on macOS..."
echo ""

# 매크로 테스트만 실행 (--filter 옵션 사용)
swift test --filter KarrotListKitMacrosTests

# 테스트 결과 확인
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Macro tests passed successfully!"
else
    echo ""
    echo "❌ Macro tests failed!"
    exit 1
fi