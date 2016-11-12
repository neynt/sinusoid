import React from 'react'

export default class WaveVisCanvas extends React.Component {
  render() {
    return <canvas ref="canvas" className="fullwidth_canvas"></canvas>
  }
  updateCanvasSize() {
    this.props.songEngine.redraw_canvas(this.refs.canvas);
  }
  componentDidMount() {
    this.updateCanvasSize();

    let that = this;
    this.props.songEngine.add_listener(() => {
      that.props.songEngine.redraw_canvas(that.refs.canvas);
    });
  }
  componentWillUnmount() {
  }
}

