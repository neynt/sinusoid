import React from 'react'
import ReactDOM from 'react-dom'

import SinusoidGui from './gui_components/SinusoidGui.jsx'

/* The hierarchy currently looks like this:
 * SinusoidGui
 * - SideBar
 * - ContentTable
 *   - SongEditor (owns the SongEngine)
 *     - EditorVisTable
 *       - WaveVisCanvas
 *     - EditorSettings
 *     - EditorTextEditor
 */

ReactDOM.render(
  <SinusoidGui />,
  document.getElementById('root')
);
