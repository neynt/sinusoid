import React from 'react'

export default class EditorSettings extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      renderingStatus: ''
    };
    this.handleClick = this.handleClick.bind(this);
  }
  handleClick(e) {
    this.props.songEngine.renderSong();
  }
  render() {
          //<option value='coffeescript'>Coffee</option>
          //<option value='clojure'>Cljs</option>
    return (
      <div>
        <select onChange={this.props.onChangeLang} value={this.props.lang}>
          <option value='javascript'>JavaScript</option>
          <option value='livescript'>LiveScript</option>
        </select>
        <button className='PlayButton' onClick={this.handleClick}>Play</button>
        <span className='RenderingStatus' ref='renderingStatus'>
          {this.state.renderingStatus}
        </span>
      </div>
    );
  }
  componentDidMount() {
    this.props.songEngine.addListener('rendering_status', (msg) => {
      this.setState({renderingStatus: msg});
    });
    this.props.songEngine.addListener('error', (msg) => {
      this.setState({renderingStatus: msg});
    });
  }
}
