#!/bin/bash
if [[ -f package.json ]]; then
    echo already initialized
    exit 0
fi

# init template sources
mkdir src test
cat << EOT > src/main.ts
export const delayMillis = (delayMs: number): Promise<void> => new Promise(resolve => setTimeout(resolve, delayMs))
export const greet = (name: string): string => \`Hello \${name}\`
EOT
cat << EOT > test/main.test.ts
import { greet } from '../src/main'

test('greeting', () => {
    expect(greet('Foo')).toBe('Hello Foo')
});
EOT

# init eslint rc
cat << EOT > .eslintrc.js
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: [
    '@typescript-eslint',
  ],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
};
EOT

# init jest config
cat << EOT > jest.config.js
module.exports = {
  roots: ['<rootDir>/src'],
  testMatch: [
    "**/__tests__/**/*.+(ts|tsx|js)",
    "**/?(*.)+(spec|test).+(ts|tsx|js)"
  ],
  transform: {
    "^.+\\.(ts|tsx)$": "ts-jest"
  },
}
EOT

# init .gitignore
cat << EOT > .gitignore
/node_modules/
/build/
/lib/
/dist/
/docs/
.idea/*

.DS_Store
coverage
*.log
EOT

# init tsconfig.json
tsc --init --types node,jest --outDir ./dist/
sed -i '/"compilerOptions":/i "include":["src/**/*.ts"],"exclude":["node_modules","**/*.test.ts"],' tsconfig.json

# init package.json
yarn init -p -y
yarn add -D typescript @types/node ts-node \
    eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin \
    jest ts-jest @types/jest

sed -i '/"devDependencies":/i "scripts": {"cli": "ts-node src/cli.ts","test": "jest","lint": "eslint src/ --ext .js,.jsx,.ts,.tsx","build": "tsc -p tsconfig.json","clean": "rm -rf dist build","ts-node": "ts-node"},' package.json
