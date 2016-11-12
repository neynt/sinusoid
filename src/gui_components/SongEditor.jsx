import React from 'react'

import EditorVisTable from './EditorVisTable.jsx'
import EditorSettings from './EditorSettings.jsx'
import EditorTextEditor from './EditorTextEditor.jsx'

export default class SongEditor extends React.Component {
  render() {
    return (
      <div className="songEditor">
        <EditorVisTable songEngine={this.songEngine} />
        <EditorSettings songEngine={this.songEngine} />
        <EditorTextEditor songEngine={this.songEngine} />
      </div>
    );
  }
  componentWillMount() {
    this.songEngine = new SongEngine();
  }
}

