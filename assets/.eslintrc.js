module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 2017,
    sourceType: "module",
    ecmaFeatures: {}
  },
  extends: [
    "eslint:recommended",
    "plugin:vue/recommended"
  ],
  rules: {
    semi: "error",
    'no-unused-vars': [
      "error",
      {
        argsIgnorePattern: "^_"
      }
    ]
  }
};
