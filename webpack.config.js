module.exports = {
  entry: './index.ls',
  output: {
    filename: 'bundle.js'
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
