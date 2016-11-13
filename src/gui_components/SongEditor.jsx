import React from 'react'

import EditorVisTable from './EditorVisTable.jsx'
import EditorSettings from './EditorSettings.jsx'
import EditorTextEditor from './EditorTextEditor.jsx'

export default class SongEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      lang: 'livescript'
    }
    this.songEngine = new SongEngine();
    this.songEngine.getLang = () => this.state.lang;

    this.onChangeLang = this.onChangeLang.bind(this);
  }
  onChangeLang(e) {
    this.setState({lang: e.target.value});
  }
  render() {
    return (
      <div className="songEditor">
        <EditorVisTable songEngine={this.songEngine} />
        <EditorSettings songEngine={this.songEngine} lang={this.state.lang} onChangeLang={this.onChangeLang} />
        <EditorTextEditor songEngine={this.songEngine} lang={this.state.lang} />
      </div>
    );
  }
  componentWillMount() {
  }
}

