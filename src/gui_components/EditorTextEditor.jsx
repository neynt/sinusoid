import React from 'react'
import * as pako from 'pako'
import CodeMirror from 'codemirror'
import * as CodeMirrorJs from 'codemirror/mode/javascript/javascript'
import * as CodeMirrorCfs from 'codemirror/mode/coffeescript/coffeescript'
import * as CodeMirrorLs from 'codemirror/mode/livescript/livescript'

export default class EditorTextEditor extends React.Component {
  handleKeyDown(e) {
    if (e.ctrlKey && e.keyCode == 13) {
      this.props.songEngine.renderSong();
    }
  }
  render() {
    return (
      <div ref="editor_div"
        onKeyDown={this.handleKeyDown.bind(this)}>
        <textarea id="song_textarea"
                  ref="textarea"
                  spellCheck="false"
                  defaultValue=""></textarea>
      </div>
    );
  }
  componentDidMount() {
    this.props.songEngine.addListener('rendering_done', () => {
      window.location.hash =
        btoa(pako.deflate(this.editor.getValue(), {to: 'string'}));
    });

    this.props.songEngine.getSongSrc = () => this.editor.getValue();

    // Load from URL hash
    if (window.location.hash) {
      this.refs.textarea.value =
        pako.inflate(atob(window.location.hash.slice(1)), {to: 'string'});
    }

    this.editor = CodeMirror.fromTextArea(this.refs.textarea, {
      mode: 'livescript',
      theme: 'monokai',
      lineNumbers: true,
      autofocus: true,
      indentWithTabs: false,
      indentUnit: 2,
      tabSize: 8,
      scrollbarStyle: null,
    });
    this.editor.setOption("extraKeys", {
      Tab: function(cm) {
        if (cm.somethingSelected()) {
          cm.indentSelection("add");
        } else {
          var spaces = Array(cm.getOption("indentUnit") + 1).join(" ");
          cm.replaceSelection(spaces);
        }
      }
    });
    this.editor_elem = this.editor.getWrapperElement();
    this.editor_elem.style.height =
      (window.innerHeight - this.editor_elem.offsetTop - 20) + 'px';
  }
}

