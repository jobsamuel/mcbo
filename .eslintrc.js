module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true
  },
  'space-before-function-paren': [
    'error',
    {
      anonymous: 'always',
      named: 'always',
      asyncArrow: 'always'
    }
  ],
  extends: ['standard', 'plugin:node/recommended'],
  parserOptions: {
    ecmaVersion: 12
  },
  overrides: [
    {
      files: ['hardhat.config.js'],
      globals: { task: true }
    }
  ]
}
