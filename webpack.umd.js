const pack = require('./package.json');
const { merge } = require('webpack-merge');
const TerserPlugin = require('terser-webpack-plugin');

// build preamble
const preamble = `/*!\n  ${pack.name} – ${pack.description}\n  ${pack.author.name} ${pack.author.github} ${new Date().getFullYear()} ${pack.license}\n  ${pack.version}\n*/`;

module.exports = (argv) => merge(require('./webpack.common.js')(argv), {
  mode: 'production',
  watch: false,
  entry: './src/mojs.babel.js',
  output: {
    filename: 'mo.umd.js',
    library: 'mojs',
    libraryExport: 'default',
    libraryTarget: 'umd',
    umdNamedDefine: true,
  },
  optimization: {
    minimizer: [
      new TerserPlugin({
        extractComments: false,
        terserOptions: {
          output: {
            comments: false,
            preamble: preamble,
          },
          toplevel: true,
        },
      }),
    ],
  },
});
