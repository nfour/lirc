module.exports = {
    "verbose": true,
    "testMatch": [
        "**/*.(spec|test).coffee"
    ],
    "transform": {
        ".(coffee)": "<rootDir>/node_modules/jest-coffee-preprocessor/index.js"
    },
    "moduleFileExtensions": [
        "coffee",
        "js"
    ],
    "testPathIgnorePatterns": [
        "/node_modules/",
    ],
}
