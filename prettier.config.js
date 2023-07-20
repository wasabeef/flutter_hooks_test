/** @type {import("prettier").Config} */
module.exports = {
  singleQuote: true,
  useTabs: false,
  tabWidth: 2,
  semi: true,
  bracketSpacing: true,
  trailingComma: 'all',
  arrowParens: 'always',
  xmlWhitespaceSensitivity: 'ignore',
  plugins: ['@prettier/plugin-xml', 'prettier-plugin-packagejson'],
};
