#
#
#

XCODEBUILD:=xcodebuild
WORKSPACE:=TMPTaskCompletionManager.xcworkspace
SCHEME:=TMPTaskCompletionManager
SDK:=iphonesimulator
CONFIGURATION:=Debug

BASEOPTS=\
 -workspace ${WORKSPACE} \
 -scheme ${SCHEME} \
 -sdk ${SDK} \
 -configuration ${CONFIGURATION} \

all:
	@echo "usage: ${MAKE} {clean|build|test}"

clean build test:
	${XCODEBUILD} ${BASEOPTS} $@

check: test

# EOF
