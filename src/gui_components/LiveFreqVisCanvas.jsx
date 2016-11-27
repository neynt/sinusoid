import React from 'react'

export default class LiveFreqVisCanvas extends React.Component {
  render() {
    return <canvas ref="canvas" className="fullwidth_canvas"></canvas>
  }
  updateCanvasSize() {
  }
  componentDidMount() {
    this.updateCanvasSize();

    const songEngine = this.props.songEngine;
    const canvas = this.refs.canvas;
    const redraw = function() {
      songEngine.redrawFreqCanvas(canvas);
      requestAnimationFrame(redraw);
    }
    redraw();
  }
  componentWillUnmount() {
  }
}
