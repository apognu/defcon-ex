const path = require('path');
const glob = require('glob');

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },

  entry: {
    'app': ['./js/app.coffee'].concat(glob.sync('./vendor/**/*.js')),
  },

  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, '../priv/static/js')
  },

  module: {
    rules: [
      {
        test: /\.coffee$/,
        exclude: /node_modules/,
        use: { loader: 'coffee-loader' }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: { loader: 'babel-loader' }
      },
      {
        test: /\.s?css$/,
        use: [
          { loader: MiniCssExtractPlugin.loader },
          { loader: 'css-loader' },
          { loader: 'resolve-url-loader' },
          {
            loader: 'postcss-loader',
            options: {
              plugins: function () {
                return [require('autoprefixer')]
              }
            }
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              implementation: require('sass')
            }
          }
        ]
      }
    ]
  },

  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});
