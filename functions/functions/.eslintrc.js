module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    tsconfigRootDir: __dirname, // Adicionado para indicar a raiz do projeto
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*",
    ".eslintrc.js" // Adicione esta linha
  ],
  rules: {
    "max-len": ["error", { "code": 120 }],
    "object-curly-spacing": "off",
    "comma-dangle": "off",
    "eol-last": "off",
    "import/no-unresolved": "off"
  },
};
