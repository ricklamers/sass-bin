## Sass Dart-VM-based binary node module

This package bundles the Dart-VM based binary version of Dart Sass for use through the `npm` package manager.

You can see performance increases of around **+500%** in typical Sass projects. This is because the Dart VM executes the Dart implementation much faster than the JS compiled version of Dart Sass.

Read more here about the details of the performance difference: [https://sass-lang.com/dart-sass](https://sass-lang.com/dart-sass)

### How to install

`npm` link: [https://www.npmjs.com/package/sass-bin](https://www.npmjs.com/package/sass-bin)

Use `sass-bin` instead of `sass` in your node module `package.json` dependencies. 

### Versioning

The versioning of this package follows the version of the official implementation: [https://github.com/sass/dart-sass](https://github.com/sass/dart-sass)
