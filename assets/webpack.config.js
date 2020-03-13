const path = require('path');
const glob = require('glob');

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const PurgecssPlugin = require('purgecss-webpack-plugin');
const { VueLoaderPlugin } = require('vue-loader');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new TerserPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },

  entry: {
    'app': glob.sync('./vendor/**/*.js').concat('@babel/polyfill').concat(['./js/app.js']),
  },

  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, '../priv/static/js')
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.vue$/,
        use: ['vue-loader']
      },
      {
        test: /\.pug$/,
        use: ['pug-plain-loader']
      },
      {
        test: /\.s?(c|a)ss$/,
        use: [
          { loader: MiniCssExtractPlugin.loader },
          { loader: 'css-loader' },
          { loader: 'resolve-url-loader' },
          {
            loader: 'postcss-loader',
            options: {
              plugins: () => [
                require('autoprefixer')
              ]
            }
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              implementation: require('sass'),
              prependData: `@import "@/../css/common.scss";`,
              sassOptions: {
                fiber: require('fibers')
              }
            }
          }
        ]
      },
    ]
  },

  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new PurgecssPlugin({
      paths: glob.sync(`${__dirname}/js/**/*`, { nodir: true }),
      whitelistPatterns: [/show/]
    }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new VueLoaderPlugin()
  ],

  resolve: {
    alias: {
      '_': 'lodash',
      '@': path.resolve(__dirname, 'js'),
      'vue$': 'vue/dist/vue.esm.js'
    },
    extensions: ['*', '.js', '.vue', '.json']
  }
});
