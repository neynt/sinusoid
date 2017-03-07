module.exports = {
  entry: {
    index: './index.ls',
    worker: './worker.ls'
  },
  output: {
    filename: '[name].entry.js'
  },
  devtool: 'source-map',
  module: {
    rules: [{
      test: /\.ls$/,
      use: 'livescript-loader'
    }, {
      test: /\.jsx$/,
      loader: 'babel-loader',
      query: {
        presets: ['es2015', 'react']
      }
    }]
  },
  resolve: {
    extensions: ['.js', '.json', '.coffee']
  }
};
