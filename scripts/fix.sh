echo "Closing xcode..."
kill $(ps aux | grep 'Xcode' | awk '{print $2}')
echo "Cleaning derive data..."
rm -rf ~/Library/Developer/Xcode/DerivedData
git clean -fd -x
echo "🛠 Checking Tools versions..."
./scripts/setup-python.sh
echo "🛠 Mint..."
./scripts/setup-mint.sh
echo "💻 Glass CLI running..."
./scripts/install-glass-cli.swift
echo "🚨 Destroying environment..."
glass environment destroy
echo "💿 Enviroment setup..."
glass environment setup
echo "🏁 Start xcode"
xed Walmart.xcworkspace