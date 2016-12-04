module.exports = {
  entry: {
    index: './index.ls',
    worker: './worker.ls'
  },
  output: {
    filename: '[name].entry.js'
  },
  module: {
    loaders: [
      {
        test: /\.ls$/,
        loader: 'livescript-loader'
      },
      {
        test: /\.jsx$/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react']
        }
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.json', '.coffee']
  }
};
