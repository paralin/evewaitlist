#!/bin/bash
if [ ! -f ./.git/hooks/pre-commit ]; then
  echo "#!/bin/bash" > ./.git/hooks/pre-commit
  echo "bash ./ch.bash" >> ./.git/hooks/pre-commit
  chmod +x ./.git/hooks/pre-commit
  echo "Created pre-commit hook"
fi
VERSION=`git describe --always --tags --dirty`
echo "@gitid = \"$VERSION\"" > version.coffee
git add version.coffee
