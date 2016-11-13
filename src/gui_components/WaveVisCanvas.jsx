import React from 'react'

export default class WaveVisCanvas extends React.Component {
  render() {
    return <canvas ref="canvas" className="fullwidth_canvas"></canvas>
  }
  updateCanvasSize() {
    this.props.songEngine.redrawCanvas(this.refs.canvas);
  }
  componentDidMount() {
    this.updateCanvasSize();

    let that = this;
    this.props.songEngine.addListener('rendering_done', () => {
      that.props.songEngine.redrawCanvas(that.refs.canvas);
    });
  }
  componentWillUnmount() {
  }
}
