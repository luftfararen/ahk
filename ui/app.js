/* ============================================================================
   INI PARSER & DOCUMENT OBJECT
   ============================================================================ */
class IniDocument {
    constructor() {
        this.lines = [];
    }

    parse(text) {
        this.lines = [];
        const rawLines = text.split(/\r?\n/);
        let currentSection = null;

        for (let rawLine of rawLines) {
            const trimmed = rawLine.trim();
            
            // Empty line
            if (trimmed === '') {
                this.lines.push({ type: 'empty', raw: rawLine, section: currentSection });
                continue;
            }

            // Comment line
            if (trimmed.startsWith(';')) {
                this.lines.push({ type: 'comment', content: trimmed, raw: rawLine, section: currentSection });
                continue;
            }

            // Section line
            const sectionMatch = trimmed.match(/^\[(.*?)\]\s*(;.*)?$/);
            if (sectionMatch) {
                currentSection = sectionMatch[1].trim();
                this.lines.push({ 
                    type: 'section', 
                    name: currentSection, 
                    comment: sectionMatch[2] || '', 
                    raw: rawLine 
                });
                continue;
            }

            // Key-Value line
            const kvMatch = rawLine.match(/^\s*([^=]+?)\s*=\s*(.*?)\s*$/);
            if (kvMatch) {
                const key = kvMatch[1].trim();
                let rawVal = kvMatch[2];
                let value = rawVal;
                let inlineComment = '';

                // Extract inline comment if prefixed by space-semicolon or tab-semicolon
                const commentIndex = Math.max(rawVal.indexOf(' ;'), rawVal.indexOf('\t;'));
                if (commentIndex !== -1) {
                    value = rawVal.substring(0, commentIndex).trim();
                    inlineComment = rawVal.substring(commentIndex).trim();
                }

                value = value.trim();
                if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
                    value = value.substring(1, value.length - 1);
                }

                this.lines.push({
                    type: 'keyvalue',
                    section: currentSection,
                    key: key,
                    value: value,
                    inlineComment: inlineComment,
                    raw: rawLine
                });
                continue;
            }

            // Unknown line (unparsed)
            this.lines.push({ type: 'unknown', raw: rawLine, section: currentSection });
        }
    }

    toString() {
        return this.lines.map(line => {
            if (line.type === 'keyvalue') {
                const indent = line.raw.match(/^\s*/)[0]; // Preserve leading indentation
                const inline = line.inlineComment ? ' ' + line.inlineComment : '';
                return `${indent}${line.key}=${line.value}${inline}`;
            }
            return line.raw;
        }).join('\n');
    }

    getSections() {
        const sections = new Set();
        for (let line of this.lines) {
            if (line.type === 'section') {
                sections.add(line.name);
            }
        }
        return Array.from(sections);
    }

    getKeys(section) {
        const result = [];
        for (let line of this.lines) {
            if (line.type === 'keyvalue' && line.section === section) {
                result.push({ key: line.key, value: line.value, inlineComment: line.inlineComment });
            }
        }
        return result;
    }

    getSectionKeys(section) {
        const result = [];
        for (let line of this.lines) {
            if (line.type === 'keyvalue' && line.section === section) {
                result.push(line.key);
            }
        }
        return result;
    }

    getValue(section, key, defaultValue = '') {
        const line = this.lines.find(l => l.type === 'keyvalue' && l.section === section && l.key.toLowerCase() === key.toLowerCase());
        if (!line) return defaultValue;
        
        let v = line.value;
        if (typeof v === 'string') {
            v = v.split(/\s+/).map(x => x.toLowerCase() === '{sc027}' ? ';' : x).join(' ');
        }
        return v;
    }

    setValue(section, key, value) {
        let v = value;
        if (typeof v === 'string') {
            v = v.split(/\s+/).map(x => x === ';' ? '{sc027}' : x).join(' ');
        }
        const lineIndex = this.lines.findIndex(l => l.type === 'keyvalue' && l.section === section && l.key.toLowerCase() === key.toLowerCase());
        if (lineIndex !== -1) {
            this.lines[lineIndex].value = v;
        } else {
            // Find section header
            const secIndex = this.lines.findIndex(l => l.type === 'section' && l.name === section);
            if (secIndex === -1) {
                // Create section at the end
                this.lines.push({ type: 'empty', raw: '' });
                this.lines.push({ type: 'section', name: section, comment: '', raw: `[${section}]` });
                this.lines.push({ type: 'keyvalue', section: section, key: key, value: v, inlineComment: '', raw: `${key}=${v}` });
            } else {
                // Find last line of section
                let insertAt = secIndex;
                for (let i = secIndex + 1; i < this.lines.length; i++) {
                    if (this.lines[i].type === 'section') {
                        break;
                    }
                    insertAt = i;
                }
                this.lines.splice(insertAt + 1, 0, {
                    type: 'keyvalue',
                    section: section,
                    key: key,
                    value: v,
                    inlineComment: '',
                    raw: `${key}=${v}`
                });
            }
        }
    }

    renameSection(oldName, newName) {
        this.lines.forEach(line => {
            if (line.type === 'section' && line.name === oldName) {
                line.name = newName;
                line.raw = `[${newName}]` + (line.comment ? ' ' + line.comment : '');
            } else if (line.section === oldName) {
                line.section = newName;
            }
        });
    }

    deleteKey(section, key) {
        const idx = this.lines.findIndex(l => l.type === 'keyvalue' && l.section === section && l.key.toLowerCase() === key.toLowerCase());
        if (idx !== -1) {
            this.lines.splice(idx, 1);
        }
    }

    deleteSection(section) {
        this.lines = this.lines.filter(l => !(l.section === section || (l.type === 'section' && l.name === section)));
    }
}

/* ============================================================================
   GLOBAL DATA & CONSTANTS
   ============================================================================ */
// 48 QWERTY Keys on Japanese JIS keyboard mapping
const QWERTY_CHARS = [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "^", "¥",
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "@", "[",
    "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", ":", "]",
    "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "\\"
];

const KEYBOARD_ROWS = [
    { rowId: 0, range: [0, 12] },  // 13 keys
    { rowId: 1, range: [13, 24] }, // 12 keys
    { rowId: 2, range: [25, 36] }, // 12 keys
    { rowId: 3, range: [37, 47] }  // 11 keys
];

// Normalized names for AHK config entry keys (same as sands.ahk EntryName)
const ENTRY_NAME_MAP = {
    ";": "semicolon",
    ":": "colon",
    ",": "comma",
    ".": "period",
    "/": "slash",
    "¥": "yen",
    "\\": "backslash",
    "^": "hat",
    "-": "minus",
    "[": "openbracket",
    "]": "closebracket",
    "1": "one",
    "2": "two",
    "3": "three",
    "4": "four",
    "5": "five",
    "6": "six",
    "7": "seven",
    "8": "eight",
    "9": "nine",
    "0": "zero",
    "space": "space",
    "tab": "tab",
    "noconv": "noconv",
    "conv": "conv",
    "f14": "f14",
    "enter": "enter",
    "up": "up",
    "down": "down",
    "left": "left",
    "right": "right"
};

function getEntryName(c) {
    if (!c) return "";
    const lower = c.toLowerCase();
    return ENTRY_NAME_MAP[lower] || lower;
}

// Display-friendly names for virtual keys
const DISP_CHAR_MAP = {
    "semicolon": ";", "colon": ":", "comma": ",", "period": ".", "slash": "/", "yen": "¥",
    "backslash": "\\", "hat": "^", "minus": "-", "openbracket": "[", "closebracket": "]"
};

function getDispChar(name) {
    return DISP_CHAR_MAP[name] || name;
}

// Default Shift characters for JIS layout
const JIS_SHIFT_DEFAULTS = {
    "1": "!", "2": "\"", "3": "#", "4": "$", "5": "%", "6": "&", "7": "'", "8": "(", "9": ")", "0": "0",
    "-": "=", "^": "~", "¥": "|",
    "q": "Q", "w": "W", "e": "E", "r": "R", "t": "T", "y": "Y", "u": "U", "i": "I", "o": "O", "p": "P", "@": "`", "[": "{",
    "a": "A", "s": "S", "d": "D", "f": "F", "g": "G", "h": "H", "j": "J", "k": "K", "l": "L", ";": "+", ":": "*", "]": "}",
    "z": "Z", "x": "X", "c": "C", "v": "V", "b": "B", "n": "N", "m": "M", ",": "<", ".": ">", "/": "?", "\\": "_"
};

const DEFAULT_CONFIG_CONTENT = `[Settings]
ImeIndicatorEnabled=1
StartupLayout=FMIX13f-Minato
HoldTh=300
LayerHoldTh=150 ;Layers.HoldThに設定される
b_time=50
LogEnabled=0
MaxLog=5000
space=NAVI_CTRL
noconv=SHORTCUT_CTRL

[1]
ver = 2
Name=FMIX13f-Minato
Layout=FMIX13f
LayoutIME=Minato

[2]
ver = 2 ;ver2の利用を推奨
Name=FMIX13f-Kanade
Layout=FMIX13
LayoutIME=Kanade

[FMIX13]
Mode=1 ;LKeyのモード指定
L00= 1 2 3 4 5 6 7 8 9 0 - ^ \\
L01= q w r l k y f u p {sc027} @ [
L02= a s d t g h n e i o : ]
L03= z x c v b j m , . / \\

[Minato]
Mode=4 ;LKeyのモード指定
L00= 1 2 3 4 5 6 7 8 9 0 - ^ \\
L01= q w d r f y l u p {sc027} @ [
L02= a s k t g h n e i o : ]
L03= z x c v b j m , . / \\

[Kanade]
Mode=4 ;LKeyのモード指定
L00= 1 2 3 4 5 6 7  8 9  0 - ^ \\
L01= q w r p l f yu u yo - @ [
L02= k s t n h {sc027} a  i e  o : ]
L03= g z d m b j m  , .  / \\
S00= 1 2 3 4 5 6 7   8  9  0 - ^ \\
S01= q w r p l f yu  u  yo - @ [
S02= k s t n h {sc027} ya  xi xe o : ]
S03= [ ] d m b j ltu ,  .  / \\
m_r_p = areru

[NAVI_CTRL]
h={Left}
j={Down}
k={Up}
l={Right}
u={Home}
o={End}
n={BackSpace}

[SHORTCUT_CTRL]
a=^a
s=^s
c=^c
v=^v
`;

/* ============================================================================
   INDEXEDDB HELPERS FOR FILE HANDLE PERSISTENCE
   ============================================================================ */
const DB_NAME = 'KeyLayoutConfigEditorDB';
const STORE_NAME = 'handles';
const KEY_NAME = 'configIniHandle';

function openDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, 1);
        request.onupgradeneeded = (e) => {
            e.target.result.createObjectStore(STORE_NAME);
        };
        request.onsuccess = (e) => resolve(e.target.result);
        request.onerror = (e) => reject(e.target.error);
    });
}

async function getStoredHandle() {
    try {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE_NAME, 'readonly');
            const store = tx.objectStore(STORE_NAME);
            const request = store.get(KEY_NAME);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    } catch (e) {
        console.error("Failed to read handle from IndexedDB:", e);
        return null;
    }
}

async function storeHandle(handle) {
    try {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const tx = db.transaction(STORE_NAME, 'readwrite');
            const store = tx.objectStore(STORE_NAME);
            const request = store.put(handle, KEY_NAME);
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    } catch (e) {
        console.error("Failed to write handle to IndexedDB:", e);
    }
}

/* ============================================================================
   APPLICATION STATE & CONTROLLER
   ============================================================================ */
const App = {
    doc: new IniDocument(),
    fileHandle: null,
    isModified: false,
    
    // UI Navigation State
    currentPanel: 'panel-settings',
    activeLayoutSlot: null,  // Numbered slot (e.g. "1")
    activeLayoutSec: null,   // Section name (e.g. "FMIX13")
    activeLayoutTab: 'normal',
    activeLayerName: null,   // Section name (e.g. "NAVI_CTRL")

    // Key selection in Layout Editor
    selectedKeyIndex: null, // Index 0-47 in QWERTY_CHARS
    selectedLayerKey: null,

    init() {
        this.setupEventHandlers();
        this.tryAutoload();
    },

    setupEventHandlers() {
        // Sidebar Navigation
        document.querySelectorAll('.nav-menu > .menu-section > a').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const panelId = item.getAttribute('data-panel');
                this.switchPanel(panelId);
                
                document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                item.classList.add('active');
            });
        });

        // File Operation Buttons
        document.getElementById('btn-open-file').addEventListener('click', () => this.openFile());
        document.getElementById('btn-save-file').addEventListener('click', () => this.saveFileDirect());
        
        // Layout Export/Import Buttons
        document.getElementById('btn-export-layout').addEventListener('click', () => this.exportLayout());
        document.getElementById('btn-import-layout').addEventListener('click', () => this.importLayoutClick());
        document.getElementById('layout-file-input').addEventListener('change', (e) => this.handleLayoutImport(e));
        
        // Fallback File Input
        document.getElementById('file-input-fallback').addEventListener('change', (e) => this.handleFallbackFileInput(e));

        // Settings inputs
        document.getElementById('setting-startup-layout').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'StartupLayout', e.target.value);
            this.markModified();
        });
        document.getElementById('setting-hold-th').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'HoldTh', e.target.value);
            this.markModified();
        });
        document.getElementById('setting-layer-hold-th').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'LayerHoldTh', e.target.value);
            this.markModified();
        });
        document.getElementById('setting-b-time').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'b_time', e.target.value);
            this.markModified();
        });
        document.getElementById('setting-b-time2').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'b_time2', e.target.value);
            this.markModified();
        });
        document.getElementById('setting-ime-indicator').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'ImeIndicatorEnabled', e.target.checked ? "1" : "0");
            this.markModified();
        });
        document.getElementById('setting-log-enabled').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'LogEnabled', e.target.checked ? "1" : "0");
            this.markModified();
        });
        document.getElementById('setting-max-log').addEventListener('change', (e) => {
            this.doc.setValue('Settings', 'MaxLog', e.target.value);
            this.markModified();
        });

        // Add Buttons in Sidebar
        document.getElementById('btn-add-layout-slot').addEventListener('click', () => {
            this.populateSlotModalDropdowns();
            showModal('modal-add-layout-slot');
        });
        document.getElementById('btn-add-layout').addEventListener('click', () => showModal('modal-add-layout'));
        document.getElementById('btn-add-layer').addEventListener('click', () => showModal('modal-add-layer'));

        // Slot Editor Inputs
        document.getElementById('slot-name-input').addEventListener('input', (e) => {
            if (this.activeLayoutSlot) {
                this.doc.setValue(this.activeLayoutSlot, 'Name', e.target.value);
                this.renderSidebarLists();
                this.populateStartupLayoutDropdown(); // 起動時レイアウトのリストを更新
                document.getElementById('slot-title').innerHTML = `レイアウトスロット設定 <span>[${this.activeLayoutSlot}] - ${e.target.value}</span>`;
                this.markModified();
            }
        });

        document.getElementById('slot-layout-select').addEventListener('change', (e) => {
            if (this.activeLayoutSlot) {
                this.doc.setValue(this.activeLayoutSlot, 'Layout', e.target.value);
                this.markModified();
            }
        });

        document.getElementById('slot-layout-ime-select').addEventListener('change', (e) => {
            if (this.activeLayoutSlot) {
                if (e.target.value === "") {
                    this.doc.deleteKey(this.activeLayoutSlot, 'LayoutIME');
                } else {
                    this.doc.setValue(this.activeLayoutSlot, 'LayoutIME', e.target.value);
                }
                this.markModified();
            }
        });

        document.getElementById('btn-delete-slot').addEventListener('click', () => {
            if (this.activeLayoutSlot && confirm(`レイアウトスロット [${this.activeLayoutSlot}] を削除しますか？`)) {
                this.doc.deleteSection(this.activeLayoutSlot);
                this.activeLayoutSlot = null;
                this.renderSidebarLists();
                this.populateStartupLayoutDropdown(); // 起動時レイアウトのリストを更新
                this.switchPanel('panel-settings');
                this.markModified();
            }
        });

        // Key Layout Editor Section Renaming
        document.getElementById('layout-section-name-input').addEventListener('change', (e) => {
            if (this.activeLayoutSec) {
                const oldSec = this.activeLayoutSec;
                const newSec = e.target.value.trim();
                
                if (!/^[A-Za-z0-9_]+$/.test(newSec)) {
                    alert("セクション名は英数字とアンダースコアのみ使用できます。");
                    e.target.value = oldSec;
                    return;
                }

                if (this.doc.getSections().includes(newSec)) {
                    alert("このセクション名は既に存在します。");
                    e.target.value = oldSec;
                    return;
                }

                this.doc.renameSection(oldSec, newSec);
                
                // Update references in Slots
                const slots = this.getLayoutSlots();
                slots.forEach(slot => {
                    if (this.doc.getValue(slot, 'Layout') === oldSec) {
                        this.doc.setValue(slot, 'Layout', newSec);
                    }
                    if (this.doc.getValue(slot, 'LayoutIME') === oldSec) {
                        this.doc.setValue(slot, 'LayoutIME', newSec);
                    }
                });

                this.activeLayoutSec = newSec;
                this.renderSidebarLists();
                this.loadLayoutSection(newSec);
                this.markModified();
            }
        });

        document.getElementById('layout-mode-select').addEventListener('change', (e) => {
            if (this.activeLayoutSec) {
                this.doc.setValue(this.activeLayoutSec, 'Mode', e.target.value);
                this.markModified();
            }
        });

        document.getElementById('keyboard-shift-toggle').addEventListener('change', () => {
            this.renderVisualKeyboard();
            this.closeKeyEditor();
        });

        // Layout Panel Tab switching
        document.querySelectorAll('.layout-tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const targetTabId = e.currentTarget.getAttribute('data-tab');
                document.querySelectorAll('.layout-tab-btn').forEach(b => b.classList.remove('active'));
                e.currentTarget.classList.add('active');
                document.querySelectorAll('.layout-tab-content').forEach(content => content.classList.remove('active'));
                const activeContent = document.getElementById(targetTabId);
                if (activeContent) activeContent.classList.add('active');
            });
        });

        // Key Editor Inputs
        document.getElementById('btn-clear-key-mapping').addEventListener('click', () => {
            document.getElementById('key-mapping-value').value = "";
        });

        // Apply mapping button in Modal
        document.getElementById('btn-apply-key-mapping').addEventListener('click', () => {
            try {
                const val = document.getElementById('key-mapping-value').value;
                const forceOverride = document.getElementById('key-override-toggle').checked;
                this.applyKeyMappingChange(val, forceOverride);
                this.closeKeyEditor();
            } catch (err) {
                console.error("Error applying key mapping:", err);
                alert("設定の適用中にエラーが発生しました: " + err.message);
            }
        });

        // Cancel mapping button in Modal
        document.getElementById('btn-cancel-key-mapping').addEventListener('click', () => {
            this.closeKeyEditor();
        });

        // Add Combination
        document.getElementById('btn-add-combination').addEventListener('click', () => {
            const key1Select = document.getElementById('add-comb-key1');
            const key2Select = document.getElementById('add-comb-key2');
            
            key1Select.innerHTML = "";
            key2Select.innerHTML = "";
            
            QWERTY_CHARS.forEach(c => {
                const addOption = (val, label) => {
                    const opt1 = document.createElement('option');
                    opt1.value = val;
                    opt1.textContent = label;
                    key1Select.appendChild(opt1);

                    const opt2 = document.createElement('option');
                    opt2.value = val;
                    opt2.textContent = label;
                    key2Select.appendChild(opt2);
                };
                addOption(c, c);
                addOption("P" + c, "P" + c + " (物理)");
            });

            // Reset inputs for new modal specification
            document.getElementById('add-comb-mode').value = "8";
            document.getElementById('add-comb-hold-th').value = "";
            document.getElementById('add-comb-b-time').value = "";
            document.getElementById('add-comb-action1').value = "";
            document.getElementById('add-comb-action2').value = "";
            document.getElementById('add-comb-action3').value = "";

            showModal('modal-add-combination');
        });

        document.getElementById('btn-add-combination-confirm').addEventListener('click', () => {
            const k1 = document.getElementById('add-comb-key1').value;
            const k2 = document.getElementById('add-comb-key2').value;
            
            const mode = document.getElementById('add-comb-mode').value;
            const holdThVal = document.getElementById('add-comb-hold-th').value.trim();
            const bTimeVal = document.getElementById('add-comb-b-time').value.trim();
            const action1 = document.getElementById('add-comb-action1').value.trim();
            const action2 = document.getElementById('add-comb-action2').value.trim();
            const action3 = document.getElementById('add-comb-action3').value.trim();

            if (!action1) {
                alert("アクション 1 は必須です。");
                return;
            }

            const holdTh = holdThVal !== "" ? parseInt(holdThVal, 10) : null;
            const bTime = bTimeVal !== "" ? parseInt(bTimeVal, 10) : null;

            const val = this.serializeCombinationValue({
                mode: parseInt(mode, 10),
                holdTh: holdTh,
                bTime: bTime,
                action1: action1,
                action2: action2,
                action3: action3
            });

            if (this.activeLayoutSec) {
                const combKey = `m_${k1}_${k2}`;
                this.doc.setValue(this.activeLayoutSec, combKey, val);
                this.renderCombinationsTable();
                closeModal('modal-add-combination');
                this.markModified();
            }
        });

        document.getElementById('btn-delete-layout').addEventListener('click', () => {
            if (this.activeLayoutSec && confirm(`キー配列定義 [${this.activeLayoutSec}] を本当に削除しますか？`)) {
                this.doc.deleteSection(this.activeLayoutSec);
                
                // Clear slot references
                const slots = this.getLayoutSlots();
                slots.forEach(slot => {
                    if (this.doc.getValue(slot, 'Layout') === this.activeLayoutSec) {
                        this.doc.deleteKey(slot, 'Layout');
                    }
                    if (this.doc.getValue(slot, 'LayoutIME') === this.activeLayoutSec) {
                        this.doc.deleteKey(slot, 'LayoutIME');
                    }
                });

                this.activeLayoutSec = null;
                this.renderSidebarLists();
                this.switchPanel('panel-settings');
                this.markModified();
            }
        });

        // Modifier Layer Section Renaming
        document.getElementById('layer-section-name-input').addEventListener('change', (e) => {
            if (this.activeLayerName) {
                const oldSec = this.activeLayerName;
                const newSec = e.target.value.trim();
                
                if (!/^[A-Za-z0-9_]+$/.test(newSec)) {
                    alert("セクション名は英数字とアンダースコアのみ使用できます。");
                    e.target.value = oldSec;
                    return;
                }

                if (this.doc.getSections().includes(newSec)) {
                    alert("このセクション名は既に存在します。");
                    e.target.value = oldSec;
                    return;
                }

                this.doc.renameSection(oldSec, newSec);
                
                // Update references in Settings modifiers
                const modifiers = ["space", "noconv", "conv", "tab", "f13", "f14"];
                modifiers.forEach(mod => {
                    if (this.doc.getValue('Settings', mod) === oldSec) {
                        this.doc.setValue('Settings', mod, newSec);
                    }
                });

                this.activeLayerName = newSec;
                this.renderSidebarLists();
                this.loadLayerMap(newSec);
                this.renderDynamicLayersTable();
                this.markModified();
            }
        });

        document.getElementById('btn-delete-layer').addEventListener('click', () => {
            if (this.activeLayerName && confirm(`モディファイアレイヤー [${this.activeLayerName}] を本当に削除しますか？`)) {
                this.doc.deleteSection(this.activeLayerName);
                
                // Clear Settings references
                const modifiers = ["space", "noconv", "conv", "tab", "f13", "f14"];
                modifiers.forEach(mod => {
                    if (this.doc.getValue('Settings', mod) === this.activeLayerName) {
                        this.doc.deleteKey('Settings', mod);
                    }
                });

                this.activeLayerName = null;
                this.renderSidebarLists();
                this.renderDynamicLayersTable();
                this.switchPanel('panel-settings');
                this.markModified();
            }
        });

        document.getElementById('btn-add-layer-map').addEventListener('click', () => {
            const physKey = prompt("マップする物理キー (QWERTY) を入力してください (例: h, j, a, semicolon):");
            if (physKey) {
                const mapVal = prompt(`キー "${physKey}" を押した時の送信コマンドを入力してください (例: {Left}, ^c):`);
                if (mapVal) {
                    const entry = getEntryName(physKey);
                    this.doc.setValue(this.activeLayerName, entry, mapVal);
                    this.loadLayerMap(this.activeLayerName);
                    this.markModified();
                }
            }
        });

        // Add Layout Slot Submit
        document.getElementById('btn-add-layout-slot-confirm').addEventListener('click', () => {
            const name = document.getElementById('add-slot-name').value.trim();
            const laySec = document.getElementById('add-slot-layout').value;
            const layImeSec = document.getElementById('add-slot-layout-ime').value;

            if (!name) {
                alert("スロット表示名は必須です。");
                return;
            }

            // Find next free numbered slot
            let nextSlot = 1;
            while (this.doc.getSections().includes(nextSlot.toString())) {
                nextSlot++;
            }

            const slotStr = nextSlot.toString();
            this.doc.setValue(slotStr, 'ver', '2');
            this.doc.setValue(slotStr, 'Name', name);
            if (laySec) this.doc.setValue(slotStr, 'Layout', laySec);
            if (layImeSec) this.doc.setValue(slotStr, 'LayoutIME', layImeSec);

            closeModal('modal-add-layout-slot');
            this.renderSidebarLists();
            this.populateStartupLayoutDropdown(); // 起動時レイアウトのリストを更新
            this.loadLayoutSlot(slotStr);
            this.switchPanel('panel-slot');

            // Highlight in sidebar
            document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
            const selector = `.nav-item[data-slot="${slotStr}"]`;
            const sidebarItem = document.querySelector(selector);
            if (sidebarItem) sidebarItem.classList.add('active');

            this.markModified();
        });

        // Add Layout Section Submit
        document.getElementById('btn-add-layout-confirm').addEventListener('click', () => {
            const secName = document.getElementById('add-layout-section-name').value.trim();
            const template = document.getElementById('add-layout-template').value;

            if (!secName) {
                alert("セクション名は必須です。");
                return;
            }

            if (this.doc.getSections().includes(secName)) {
                alert("このセクション名は既に存在します。");
                return;
            }

            this.createLayoutSectionFromTemplate(secName, template);

            closeModal('modal-add-layout');
            this.renderSidebarLists();
            this.loadLayoutSection(secName);
            this.switchPanel('panel-layout');

            // Highlight in sidebar
            document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
            const selector = `.nav-item[data-layout="${secName}"]`;
            const sidebarItem = document.querySelector(selector);
            if (sidebarItem) sidebarItem.classList.add('active');

            this.markModified();
        });

        // Add Modifier Layer Submit
        document.getElementById('btn-add-layer-confirm').addEventListener('click', () => {
            const name = document.getElementById('add-layer-name').value.trim();
            const template = document.getElementById('add-layer-template').value;

            if (!name) {
                alert("レイヤーセクション名は必須です。");
                return;
            }

            if (this.doc.getSections().includes(name)) {
                alert("このセクション名は既に存在します。");
                return;
            }

            // Create Section
            this.doc.setValue(name, '; new layer', ''); 
            this.doc.deleteKey(name, '; new layer'); 

            if (template === 'navi') {
                this.doc.setValue(name, 'h', '{Left}');
                this.doc.setValue(name, 'j', '{Down}');
                this.doc.setValue(name, 'k', '{Up}');
                this.doc.setValue(name, 'l', '{Right}');
                this.doc.setValue(name, 'u', '{Home}');
                this.doc.setValue(name, 'o', '{End}');
                this.doc.setValue(name, 'n', '{BackSpace}');
            } else if (template === 'shortcut') {
                this.doc.setValue(name, 'a', '^a');
                this.doc.setValue(name, 's', '^s');
                this.doc.setValue(name, 'c', '^c');
                this.doc.setValue(name, 'v', '^v');
            }

            closeModal('modal-add-layer');
            this.renderSidebarLists();
            this.loadLayerMap(name);
            this.switchPanel('panel-layer');

            // Highlight in sidebar
            document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
            const selector = `.nav-item[data-layer="${name}"]`;
            const sidebarItem = document.querySelector(selector);
            if (sidebarItem) sidebarItem.classList.add('active');

            this.markModified();
        });

        // Raw Edit Panel buttons
        document.getElementById('btn-apply-raw').addEventListener('click', () => {
            const val = document.getElementById('raw-textarea').value;
            this.doc.parse(val);
            this.isModified = true;
            this.updateStatusBar();
            this.loadDocumentData();
        });
    },

    /* ============================================================================
       LOAD & PARSE FUNCTIONS
       ============================================================================ */
    async tryAutoload() {
        // 0. Try loading from URL hash (passed from AutoHotkey launch to bypass file:// CORS restriction)
        const hash = window.location.hash;
        if (hash.startsWith('#ini=')) {
            try {
                const hexData = hash.substring(5);
                const bytes = new Uint8Array(hexData.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));
                const text = new TextDecoder().decode(bytes);
                this.doc.parse(text);
                this.isModified = false;
                document.getElementById('file-status').textContent = 'Loaded: config.ini (Auto via AHK)';
                document.getElementById('file-status').className = 'status-indicator success';
                this.loadDocumentData();
                
                // Clear the hash to keep the URL clean
                try {
                    history.replaceState(null, document.title, window.location.pathname + window.location.search);
                } catch (e) {}
                return;
            } catch (e) {
                console.error("Failed to parse URL hash config:", e);
            }
        }

        // 1. IndexedDBからファイルハンドルを復元してみる
        try {
            const handle = await getStoredHandle();
            if (handle) {
                this.fileHandle = handle;
                console.log("Restored file handle from IndexedDB:", handle);
                
                // 読み取り許可を確認
                const opts = { mode: 'readwrite' };
                if ((await handle.queryPermission(opts)) === 'granted') {
                    // ファイルを読み込んで適用
                    const file = await handle.getFile();
                    const text = await file.text();
                    this.doc.parse(text);
                    this.isModified = false;
                    document.getElementById('file-status').textContent = `Loaded: ${file.name} (Direct Sync Active)`;
                    document.getElementById('file-status').className = 'status-indicator success';
                    this.loadDocumentData();
                    return;
                } else {
                    console.log("Handle exists but permission is not granted yet.");
                }
            }
        } catch (e) {
            console.error("Failed to restore handle on startup:", e);
        }

        // 2. フォールバック: fetch での自動ロードを試みる
        try {
            // Attempt to load ../config.ini automatically
            const response = await fetch('../config.ini');
            if (response.ok) {
                const text = await response.text();
                this.doc.parse(text);
                this.isModified = false;
                document.getElementById('file-status').textContent = 'Loaded: ../config.ini (Auto)';
                document.getElementById('file-status').className = 'status-indicator success';
                this.loadDocumentData();
                return;
            }
        } catch (e) {
            console.log("Auto-load fetched ../config.ini failed (expected in local browsers): ", e);
        }

        // 3. ローカルストレージのキャッシュから復元を試みる
        try {
            const cachedText = localStorage.getItem('config_ini_cache');
            if (cachedText) {
                this.doc.parse(cachedText);
                this.isModified = false;
                document.getElementById('file-status').textContent = 'Loaded: config.ini (Local Cache)';
                document.getElementById('file-status').className = 'status-indicator success';
                this.loadDocumentData();
                return;
            }
        } catch (e) {
            console.error("Failed to read from localStorage cache:", e);
        }

        // 4. デモデータを読み込み
        this.doc.parse(DEFAULT_CONFIG_CONTENT);
        document.getElementById('file-status').textContent = 'デモ設定ファイル表示中（保存にはファイルを開いてください）';
        document.getElementById('file-status').className = 'status-indicator warning';
        this.loadDocumentData();
    },

    async openFile() {
        if (window.showOpenFilePicker) {
            try {
                const [handle] = await window.showOpenFilePicker({
                    types: [{
                        description: 'Configuration INI File',
                        accept: { 'text/plain': ['.ini'] }
                    }],
                    multiple: false
                });
                this.fileHandle = handle;
                await storeHandle(handle); // IndexedDBに保存
                const file = await handle.getFile();
                const text = await file.text();
                
                this.doc.parse(text);
                this.isModified = false;
                
                document.getElementById('file-status').textContent = `Loaded: ${file.name}`;
                document.getElementById('file-status').className = 'status-indicator success';
                
                this.loadDocumentData();
            } catch (err) {
                console.error("File selection canceled or failed", err);
            }
        } else {
            // Fallback to input file upload
            document.getElementById('file-input-fallback').click();
        }
    },

    handleFallbackFileInput(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            const text = event.target.result;
            this.doc.parse(text);
            this.isModified = false;
            this.fileHandle = null; 
            
            document.getElementById('file-status').textContent = `Loaded: ${file.name} (Direct Save Disabled)`;
            document.getElementById('file-status').className = 'status-indicator warning';
            
            this.loadDocumentData();
        };
        reader.readAsText(file);
    },

    async saveFileDirect() {
        const text = this.doc.toString();
        
        // 1. Try direct HTTP PUT first (useful for WebView2 / local servers)
        try {
            const response = await fetch('../config.ini', {
                method: 'PUT',
                headers: { 'Content-Type': 'text/plain' },
                body: text
            });
            if (response.ok) {
                this.isModified = false;
                this.updateStatusBar();
                this.clearSaveButtonHighlight();
                alert("config.ini を保存しました。");
                return;
            }
        } catch (e) {
            console.log("Direct PUT save failed, trying fallback...", e);
        }

        // 2. Try File System Access API
        let handle = this.fileHandle;
        
        // If we have a handle, check and request permissions
        if (handle) {
            const opts = { mode: 'readwrite' };
            try {
                if ((await handle.queryPermission(opts)) !== 'granted') {
                    if ((await handle.requestPermission(opts)) !== 'granted') {
                        handle = null; // User denied permission, force new picker
                    }
                }
            } catch (err) {
                console.error("Permission check failed, prompting picker", err);
                handle = null;
            }
        }

        // If no handle is available or permission was denied, prompt picker (skip on file://)
        if (!handle && window.showOpenFilePicker && window.location.protocol !== 'file:') {
            try {
                const [newHandle] = await window.showOpenFilePicker({
                    types: [{
                        description: 'INI Configuration File',
                        accept: { 'text/plain': ['.ini'] }
                    }],
                    multiple: false
                });
                handle = newHandle;
                this.fileHandle = handle;
                await storeHandle(handle); // Save to IndexedDB
            } catch (err) {
                console.warn("User cancelled file picker or showOpenFilePicker is not supported", err);
            }
        }

        // Write directly to file if handle is resolved
        if (handle) {
            try {
                const writable = await handle.createWritable();
                await writable.write(text);
                await writable.close();
                this.isModified = false;
                this.updateStatusBar();
                this.clearSaveButtonHighlight();
                alert("config.ini を上書き保存しました。");
                
                // Status bar details update
                const file = await handle.getFile();
                document.getElementById('file-status').textContent = `Loaded: ${file.name} (Direct Sync Active)`;
                document.getElementById('file-status').className = 'status-indicator success';
                return;
            } catch (err) {
                console.error("Failed to write using File System Access API", err);
                alert("ファイルの保存に失敗しました: " + err.message);
            }
        } else {
            // 3. Fallback to standard download
            this.downloadFile();
        }
    },

    downloadFile() {
        const blob = new Blob([this.doc.toString()], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'config.ini';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        this.isModified = false;
        this.updateStatusBar();
        this.clearSaveButtonHighlight();
    },

    async exportLayout() {
        if (!this.activeLayoutSec) {
            alert("エクスポートするレイアウトが選択されていません。");
            return;
        }
        const section = this.activeLayoutSec;

        // 1. Call showSaveFilePicker IMMEDIATELY to satisfy browser user gesture rules (skip on file://)
        let handle = null;
        let savedDirectly = false;
        if (window.showSaveFilePicker && window.location.protocol !== 'file:') {
            try {
                handle = await window.showSaveFilePicker({
                    suggestedName: `${section}.klt`,
                    types: [{
                        description: 'Key Layout Template',
                        accept: { 'text/plain': ['.klt'] }
                    }]
                });
            } catch (err) {
                console.error("Export layout via File System Access API failed:", err);
                if (err.name === 'AbortError') {
                    return; // User cancelled explicitly
                }
            }
        }

        // 2. Construct the layout content ONLY after dialog resolves or falls back
        const keys = this.doc.getSectionKeys(section);
        let out = `[${section}]\n`;
        keys.forEach(k => {
            const v = this.doc.getValue(section, k); // getValue returns decoded string
            let encodedVal = v;
            if (typeof v === 'string') {
                encodedVal = v.split(/\s+/).map(x => x === ';' ? '{sc027}' : x).join(' ');
            }
            out += `${k}=${encodedVal}\n`;
        });

        // 3. Save directly using handle if acquired
        if (handle) {
            try {
                const writable = await handle.createWritable();
                await writable.write(out);
                await writable.close();
                alert("レイアウトを保存しました。");
                savedDirectly = true;
            } catch (err) {
                console.error("Failed to write to acquired file handle:", err);
            }
        }

        // Fallback to classic download if API failed or was unsupported
        if (!savedDirectly) {
            try {
                const blob = new Blob([out], { type: 'text/plain;charset=utf-8' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `${section}.klt`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                alert("ブラウザ制限のため、ファイルをダウンロードフォルダにダウンロードしました。");
            } catch (fallbackErr) {
                console.error("Layout export fallback failed:", fallbackErr);
                alert("レイアウトのエクスポートに失敗しました。");
            }
        }
    },

    async importLayoutClick() {
        let importedDirectly = false;
        if (window.showOpenFilePicker && window.location.protocol !== 'file:') {
            try {
                const [handle] = await window.showOpenFilePicker({
                    types: [{
                        description: 'Key Layout Template',
                        accept: { 'text/plain': ['.klt'] }
                    }],
                    multiple: false
                });
                const file = await handle.getFile();
                const text = await file.text();
                this.processLayoutImportText(text);
                importedDirectly = true;
            } catch (err) {
                console.error("Import layout via File System Access API failed:", err);
                if (err.name === 'AbortError') {
                    return; // User cancelled explicitly
                }
            }
        }

        // Fallback to classic file input click if API failed or was unsupported
        if (!importedDirectly) {
            try {
                document.getElementById('layout-file-input').click();
            } catch (fallbackErr) {
                console.error("Layout import fallback failed:", fallbackErr);
                alert("インポート用のファイル選択ダイアログを開けませんでした。");
            }
        }
    },

    handleLayoutImport(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            this.processLayoutImportText(event.target.result);
        };
        reader.readAsText(file);
        e.target.value = '';
    },

    processLayoutImportText(text) {
        const tempDoc = new IniDocument();
        try {
            tempDoc.parse(text);
            const sections = tempDoc.getSections();
            if (sections.length === 0) {
                alert("有効なレイアウトセクションが見つかりませんでした。");
                return;
            }
            const fileSec = sections[0];
            
            const keys = tempDoc.getSectionKeys(fileSec);
            const exists = this.doc.getSections().includes(fileSec);
            if (exists) {
                if (!confirm(`セクション [${fileSec}] は既に存在します。上書きしますか？`)) {
                    return;
                }
                this.doc.deleteSection(fileSec);
            }
            
            keys.forEach(k => {
                this.doc.setValue(fileSec, k, tempDoc.getValue(fileSec, k));
            });
            
            this.markModified();
            this.renderSidebarLists();
            this.loadLayoutSection(fileSec);
            this.switchPanel('panel-layout');
            
            alert(`レイアウト [${fileSec}] をインポートしました。`);
        } catch (err) {
            alert("インポートに失敗しました。ファイル形式を確認してください: " + err.message);
        }
    },

    markModified() {
        this.isModified = true;
        this.updateStatusBar();
        this.highlightSaveButton();
        document.getElementById('raw-textarea').value = this.doc.toString();
    },

    highlightSaveButton() {
        const saveBtn = document.getElementById('btn-save-file');
        if (saveBtn) {
            saveBtn.classList.add('glow-highlight');
        }
    },

    clearSaveButtonHighlight() {
        const saveBtn = document.getElementById('btn-save-file');
        if (saveBtn) {
            saveBtn.classList.remove('glow-highlight');
        }
    },

    updateStatusBar() {
        const statusEl = document.getElementById('file-status');
        let txt = statusEl.textContent.replace(' (変更あり)', '').replace(' (Modified)', '');
        if (this.isModified) {
            statusEl.textContent = txt + ' (変更あり)';
            statusEl.className = 'status-indicator warning';
        } else {
            statusEl.textContent = txt;
            statusEl.className = 'status-indicator success';
        }
    },

    loadDocumentData() {
        // Settings values
        document.getElementById('setting-hold-th').value = this.doc.getValue('Settings', 'HoldTh', '300');
        document.getElementById('setting-layer-hold-th').value = this.doc.getValue('Settings', 'LayerHoldTh', '150');
        document.getElementById('setting-b-time').value = this.doc.getValue('Settings', 'b_time', '50');
        document.getElementById('setting-b-time2').value = this.doc.getValue('Settings', 'b_time2', '50');
        document.getElementById('setting-ime-indicator').checked = this.doc.getValue('Settings', 'ImeIndicatorEnabled', '1') === "1";
        document.getElementById('setting-log-enabled').checked = this.doc.getValue('Settings', 'LogEnabled', '0') === "1";
        document.getElementById('setting-max-log').value = this.doc.getValue('Settings', 'MaxLog', '5000');

        document.getElementById('raw-textarea').value = this.doc.toString();

        // Cache document to localStorage
        try {
            localStorage.setItem('config_ini_cache', this.doc.toString());
        } catch (e) {
            console.warn("Failed to write to localStorage:", e);
        }

        this.renderSidebarLists();
        this.renderDynamicLayersTable();
        this.populateStartupLayoutDropdown();
        this.closeKeyEditor();

        // Validate and refresh active slot
        const slots = this.getLayoutSlots();
        if (this.activeLayoutSlot) {
            if (slots.includes(this.activeLayoutSlot)) {
                this.loadLayoutSlot(this.activeLayoutSlot);
            } else {
                this.activeLayoutSlot = null;
                if (this.currentPanel === 'panel-slot') {
                    this.switchPanel('panel-settings');
                }
            }
        }

        // Validate and refresh active layout section
        const keyLayouts = this.getKeyLayoutSections();
        if (this.activeLayoutSec) {
            if (keyLayouts.includes(this.activeLayoutSec)) {
                this.loadLayoutSection(this.activeLayoutSec);
            } else {
                this.activeLayoutSec = null;
                if (this.currentPanel === 'panel-layout') {
                    this.switchPanel('panel-settings');
                }
            }
        }

        // Validate and refresh active modifier layer
        const layers = this.getModifierLayers();
        if (this.activeLayerName) {
            if (layers.includes(this.activeLayerName)) {
                this.loadLayerMap(this.activeLayerName);
            } else {
                this.activeLayerName = null;
                if (this.currentPanel === 'panel-layer') {
                    this.switchPanel('panel-settings');
                }
            }
        }

        // Highlight matching sidebar item for the current panel
        this.switchPanel(this.currentPanel);
    },

    populateStartupLayoutDropdown() {
        const select = document.getElementById('setting-startup-layout');
        select.innerHTML = "";
        
        const startup = this.doc.getValue('Settings', 'StartupLayout', '');
        const slots = this.getLayoutSlots();
        
        slots.forEach(slotNum => {
            const name = this.doc.getValue(slotNum, 'Name', `Slot ${slotNum}`);
            const opt = document.createElement('option');
            opt.value = name;
            opt.textContent = `${slotNum}: ${name}`;
            if (name === startup) {
                opt.selected = true;
            }
            select.appendChild(opt);
        });
    },

    /* ============================================================================
       SECTION CLASSIFICATION UTILITIES
       ============================================================================ */
    getLayoutSlots() {
        return this.doc.getSections().filter(sec => /^\d+$/.test(sec)).sort((a, b) => parseInt(a) - parseInt(b));
    },

    getKeyLayoutSections() {
        const slots = this.getLayoutSlots();
        const referenced = new Set();
        slots.forEach(slot => {
            const lay = this.doc.getValue(slot, 'Layout');
            const ime = this.doc.getValue(slot, 'LayoutIME');
            if (lay) referenced.add(lay);
            if (ime) referenced.add(ime);
        });
        
        const sections = this.doc.getSections();
        return sections.filter(sec => {
            if (sec === 'Settings' || /^\d+$/.test(sec)) return false;
            if (referenced.has(sec)) return true;
            
            // Check if it contains rows like L00
            const keys = this.doc.getKeys(sec).map(k => k.key.toLowerCase());
            return keys.some(k => k.startsWith('l0'));
        });
    },

    getModifierLayers() {
        const slots = new Set(this.getLayoutSlots());
        const layouts = new Set(this.getKeyLayoutSections());
        const sections = this.doc.getSections();
        
        return sections.filter(sec => {
            if (sec === 'Settings') return false;
            if (slots.has(sec)) return false;
            if (layouts.has(sec)) return false;
            return true;
        });
    },

    /* ============================================================================
       SIDEBAR & DROPDOWNS RENDERERS
       ============================================================================ */
    renderSidebarLists() {
        // 1. Layout Slots
        const slotsList = document.getElementById('layout-slots-list');
        slotsList.innerHTML = "";
        
        const slots = this.getLayoutSlots();
        if (slots.length === 0) {
            slotsList.innerHTML = '<div class="no-data">スロット未登録</div>';
        } else {
            slots.forEach(slotNum => {
                const name = this.doc.getValue(slotNum, 'Name', `Slot ${slotNum}`);
                const el = document.createElement('a');
                el.href = `#slot-${slotNum}`;
                el.className = 'nav-item';
                el.setAttribute('data-slot', slotNum);
                el.innerHTML = `<span class="icon">🔖</span> [${slotNum}] ${name}`;
                el.addEventListener('click', (e) => {
                    e.preventDefault();
                    document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                    el.classList.add('active');
                    this.loadLayoutSlot(slotNum);
                    this.switchPanel('panel-slot');
                });
                slotsList.appendChild(el);
            });
        }

        // 2. Key Layouts (Key mapping definitions)
        const layoutsList = document.getElementById('key-layouts-list');
        layoutsList.innerHTML = "";
        
        const keyLayouts = this.getKeyLayoutSections();
        if (keyLayouts.length === 0) {
            layoutsList.innerHTML = '<div class="no-data">配列定義未登録</div>';
        } else {
            keyLayouts.forEach(secName => {
                const el = document.createElement('a');
                el.href = `#layout-${secName}`;
                el.className = 'nav-item';
                el.setAttribute('data-layout', secName);
                el.innerHTML = `<span class="icon">⌨️</span> [${secName}]`;
                el.addEventListener('click', (e) => {
                    e.preventDefault();
                    document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                    el.classList.add('active');
                    this.loadLayoutSection(secName);
                    this.switchPanel('panel-layout');
                });
                layoutsList.appendChild(el);
            });
        }

        // 3. Modifier Layers
        const layersList = document.getElementById('layer-maps-list');
        layersList.innerHTML = "";
        
        const layers = this.getModifierLayers();
        if (layers.length === 0) {
            layersList.innerHTML = '<div class="no-data">レイヤー未登録</div>';
        } else {
            layers.forEach(layerName => {
                const el = document.createElement('a');
                el.href = `#layer-${layerName}`;
                el.className = 'nav-item';
                el.setAttribute('data-layer', layerName);
                el.innerHTML = `<span class="icon">🥞</span> [${layerName}]`;
                el.addEventListener('click', (e) => {
                    e.preventDefault();
                    document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                    el.classList.add('active');
                    this.loadLayerMap(layerName);
                    this.switchPanel('panel-layer');
                });
                layersList.appendChild(el);
            });
        }
    },

    populateSlotModalDropdowns() {
        const addSlotLayout = document.getElementById('add-slot-layout');
        const addSlotLayoutIme = document.getElementById('add-slot-layout-ime');
        
        addSlotLayout.innerHTML = "";
        addSlotLayoutIme.innerHTML = "";
        
        const optNone = document.createElement('option');
        optNone.value = "";
        optNone.textContent = "同上 (共通利用)";
        addSlotLayoutIme.appendChild(optNone);

        const sections = this.getKeyLayoutSections();
        sections.forEach(sec => {
            const opt1 = document.createElement('option');
            opt1.value = sec;
            opt1.textContent = sec;
            addSlotLayout.appendChild(opt1);

            const opt2 = document.createElement('option');
            opt2.value = sec;
            opt2.textContent = sec;
            addSlotLayoutIme.appendChild(opt2);
        });
    },

    renderDynamicLayersTable() {
        const body = document.getElementById('dynamic-layers-table-body');
        body.innerHTML = "";
        
        const modifiers = ["space", "noconv", "conv", "tab", "f13", "f14"];
        const layers = this.getModifierLayers();
        
        modifiers.forEach(mod => {
            const currentLayerVal = this.doc.getValue('Settings', mod, '');
            
            const tr = document.createElement('tr');
            
            const tdMod = document.createElement('td');
            tdMod.innerHTML = `<code class="font-mono">${mod}</code>`;
            tr.appendChild(tdMod);

            const tdSelect = document.createElement('td');
            const select = document.createElement('select');
            select.className = 'form-control';
            
            const optNone = document.createElement('option');
            optNone.value = "";
            optNone.textContent = "無し (未設定)";
            select.appendChild(optNone);
            
            layers.forEach(layName => {
                const opt = document.createElement('option');
                opt.value = layName;
                opt.textContent = layName;
                if (layName === currentLayerVal) {
                    opt.selected = true;
                }
                select.appendChild(opt);
            });

            select.addEventListener('change', (e) => {
                const val = e.target.value;
                if (val === "") {
                    this.doc.deleteKey('Settings', mod);
                } else {
                    this.doc.setValue('Settings', mod, val);
                }
                this.markModified();
            });

            tdSelect.appendChild(select);
            tr.appendChild(tdSelect);

            const tdAction = document.createElement('td');
            if (currentLayerVal) {
                const btn = document.createElement('button');
                btn.className = 'btn secondary btn-xs';
                btn.textContent = '編集を開く';
                btn.addEventListener('click', () => {
                    this.loadLayerMap(currentLayerVal);
                    this.switchPanel('panel-layer');
                    
                    document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                    const item = document.querySelector(`.nav-item[data-layer="${currentLayerVal}"]`);
                    if (item) item.classList.add('active');
                });
                tdAction.appendChild(btn);
            }
            tr.appendChild(tdAction);

            body.appendChild(tr);
        });
    },

    /* ============================================================================
       LAYOUT SLOT PANEL
       ============================================================================ */
    loadLayoutSlot(slotNum) {
        this.activeLayoutSlot = slotNum;
        
        const name = this.doc.getValue(slotNum, 'Name', `Slot ${slotNum}`);
        document.getElementById('slot-title').innerHTML = `レイアウトスロット設定 <span>[${slotNum}] - ${name}</span>`;
        document.getElementById('slot-name-input').value = name;

        // Populating list of layout sections for select dropdowns
        const layouts = this.getKeyLayoutSections();
        const secSelect = document.getElementById('slot-layout-select');
        const imeSecSelect = document.getElementById('slot-layout-ime-select');
        
        secSelect.innerHTML = "";
        imeSecSelect.innerHTML = "";

        const optNone = document.createElement('option');
        optNone.value = "";
        optNone.textContent = "同上 (共通利用)";
        imeSecSelect.appendChild(optNone);

        layouts.forEach(s => {
            const opt1 = document.createElement('option');
            opt1.value = s;
            opt1.textContent = s;
            secSelect.appendChild(opt1);

            const opt2 = document.createElement('option');
            opt2.value = s;
            opt2.textContent = s;
            imeSecSelect.appendChild(opt2);
        });

        const activeSec = this.doc.getValue(slotNum, 'Layout', '');
        const activeSecIME = this.doc.getValue(slotNum, 'LayoutIME', '');

        secSelect.value = activeSec;
        imeSecSelect.value = activeSecIME;
    },

    /* ============================================================================
       KEY LAYOUT PANEL
       ============================================================================ */
    loadLayoutSection(secName) {
        this.activeLayoutSec = secName;
        
        document.getElementById('visual-keyboard-sec-title').textContent = `キー配列プレビュー [${secName}]`;
        document.getElementById('layout-section-name-input').value = secName;

        const mode = this.doc.getValue(secName, 'Mode', '1');
        document.getElementById('layout-mode-select').value = mode;

        this.renderVisualKeyboard();
        this.renderLayoutOverridesTable();
        this.renderCombinationsTable();
        this.closeKeyEditor();
    },

    getKeyboardLayoutKeys(section, isShift) {
        const prefix = isShift ? "S" : "L";
        const keysArr = new Array(48).fill("");
        
        let row0 = this.doc.getValue(section, prefix + "00", "");
        let row1 = this.doc.getValue(section, prefix + "01", "");
        let row2 = this.doc.getValue(section, prefix + "02", "");
        let row3 = this.doc.getValue(section, prefix + "03", "");

        const splitRow = (rowStr) => {
            if (!rowStr) return [];
            return rowStr.trim().split(/\s+/).filter(x => x !== "");
        };

        const r0Keys = splitRow(row0);
        const r1Keys = splitRow(row1);
        const r2Keys = splitRow(row2);
        const r3Keys = splitRow(row3);

        for (let i = 0; i < 48; i++) {
            if (i < 13) {
                keysArr[i] = r0Keys[i] !== undefined ? r0Keys[i] : "";
            } else if (i < 25) {
                keysArr[i] = r1Keys[i - 13] !== undefined ? r1Keys[i - 13] : "";
            } else if (i < 37) {
                keysArr[i] = r2Keys[i - 25] !== undefined ? r2Keys[i - 25] : "";
            } else {
                keysArr[i] = r3Keys[i - 37] !== undefined ? r3Keys[i - 37] : "";
            }
        }
        return keysArr;
    },

    saveKeyboardLayoutKeys(section, isShift, keysArr) {
        const prefix = isShift ? "S" : "L";
        
        const row0 = keysArr.slice(0, 13).join(" ");
        const row1 = keysArr.slice(13, 25).join(" ");
        const row2 = keysArr.slice(25, 37).join(" ");
        const row3 = keysArr.slice(37, 48).join(" ");

        this.doc.setValue(section, prefix + "00", " " + row0);
        this.doc.setValue(section, prefix + "01", " " + row1);
        this.doc.setValue(section, prefix + "02", " " + row2);
        this.doc.setValue(section, prefix + "03", " " + row3);
        
        this.markModified();
    },

    renderVisualKeyboard() {
        const kbd = document.getElementById('virtual-keyboard');
        kbd.innerHTML = "";
        
        const section = this.activeLayoutSec;
        if (!section) {
            kbd.innerHTML = '<div class="no-data text-center p-5">配列セクションが選択されていません</div>';
            return;
        }

        const isShift = document.getElementById('keyboard-shift-toggle').checked;
        const keysArr = this.getKeyboardLayoutKeys(section, isShift);

        KEYBOARD_ROWS.forEach(row => {
            const rowDiv = document.createElement('div');
            rowDiv.className = `keyboard-row keyboard-row-${row.rowId}`;

            for (let i = row.range[0]; i <= row.range[1]; i++) {
                const physKey = QWERTY_CHARS[i];
                const entryName = getEntryName(physKey);
                
                const overrideKeyName = (isShift ? "s_" : "") + entryName;
                const overrideVal = this.doc.getValue(section, overrideKeyName, "");
                const hasOverride = overrideVal !== "";
                
                let dispVal = hasOverride ? overrideVal : keysArr[i];
                dispVal = getDispChar(dispVal);

                const keycap = document.createElement('div');
                keycap.className = 'keycap';
                if (i === this.selectedKeyIndex) {
                    keycap.classList.add('active');
                }
                if (hasOverride) {
                    keycap.classList.add('has-override');
                }
                if (!dispVal) {
                    keycap.classList.add('is-empty');
                    dispVal = isShift ? (JIS_SHIFT_DEFAULTS[physKey] || physKey.toUpperCase()) : physKey;
                }

                const cleanDisp = dispVal.startsWith('{sc') ? getDispChar(dispVal.match(/^{sc[0-9A-Fa-f]+}$/) ? dispVal.slice(1, -1) : dispVal) : dispVal;

                keycap.innerHTML = `
                    <span class="key-physical">${physKey.toUpperCase()}</span>
                    <span class="key-mapped font-mono">${cleanDisp}</span>
                `;

                keycap.addEventListener('click', () => {
                    this.selectKey(i);
                });

                rowDiv.appendChild(keycap);
            }
            kbd.appendChild(rowDiv);
        });
    },

    selectKey(idx) {
        this.selectedKeyIndex = idx;
        
        document.querySelectorAll('#virtual-keyboard .keycap').forEach((el, index) => {
            if (index === idx) {
                el.classList.add('active');
            } else {
                el.classList.remove('active');
            }
        });

        const physKey = QWERTY_CHARS[idx];
        const entryName = getEntryName(physKey);
        const section = this.activeLayoutSec;
        const isShift = document.getElementById('keyboard-shift-toggle').checked;
        const overrideKeyName = (isShift ? "s_" : "") + entryName;

        const keysArr = this.getKeyboardLayoutKeys(section, isShift);
        const overrideVal = this.doc.getValue(section, overrideKeyName, "");
        const hasOverride = overrideVal !== "";

        const mapVal = hasOverride ? overrideVal : keysArr[idx];

        document.getElementById('modal-key-editor').classList.add('show');
        document.getElementById('key-editor-physical-key').textContent = `${physKey.toUpperCase()} (${entryName})`;
        document.getElementById('key-mapping-value').value = mapVal;
        
        const badge = document.getElementById('key-editor-status-badge');
        if (hasOverride) {
            badge.textContent = "個別オーバーライド";
            badge.className = "key-status-badge override";
        } else {
            badge.textContent = "標準行配列マッピング";
            badge.className = "key-status-badge";
        }

        document.getElementById('key-override-toggle').checked = hasOverride;
    },

    applyKeyMappingChange(newVal, forceOverride = null) {
        if (this.selectedKeyIndex === null || !this.activeLayoutSec) return;

        const idx = this.selectedKeyIndex;
        const physKey = QWERTY_CHARS[idx];
        const entryName = getEntryName(physKey);
        const section = this.activeLayoutSec;
        const isShift = document.getElementById('keyboard-shift-toggle').checked;
        const overrideKeyName = (isShift ? "s_" : "") + entryName;

        const currentKeysArr = this.getKeyboardLayoutKeys(section, isShift);
        const isCurrentlyOverridden = this.doc.getValue(section, overrideKeyName, "") !== "";
        
        let setAsOverride = forceOverride !== null ? forceOverride : (isCurrentlyOverridden || newVal.includes(" "));

        if (setAsOverride) {
            this.doc.setValue(section, overrideKeyName, newVal);
            currentKeysArr[idx] = isShift ? (JIS_SHIFT_DEFAULTS[physKey] || physKey) : physKey;
            this.saveKeyboardLayoutKeys(section, isShift, currentKeysArr);
            
            document.getElementById('key-editor-status-badge').textContent = "個別オーバーライド";
            document.getElementById('key-editor-status-badge').className = "key-status-badge override";
        } else {
            this.doc.deleteKey(section, overrideKeyName);
            currentKeysArr[idx] = newVal || "";
            this.saveKeyboardLayoutKeys(section, isShift, currentKeysArr);
            
            document.getElementById('key-editor-status-badge').textContent = "標準行配列マッピング";
            document.getElementById('key-editor-status-badge').className = "key-status-badge";
        }

        this.renderVisualKeyboard();
        this.renderLayoutOverridesTable();
    },

    closeKeyEditor() {
        this.selectedKeyIndex = null;
        closeModal('modal-key-editor');
        document.querySelectorAll('#virtual-keyboard .keycap').forEach(el => {
            el.classList.remove('active');
        });
    },

    renderLayoutOverridesTable() {
        const body = document.getElementById('overrides-table-body');
        body.innerHTML = "";
        
        const section = this.activeLayoutSec;
        if (!section) return;

        const keys = this.doc.getKeys(section);
        const overrides = keys.filter(kv => {
            const k = kv.key.toLowerCase();
            return !k.startsWith('l0') && !k.startsWith('s0') && k !== 'mode' && !k.startsWith('m_');
        });

        if (overrides.length === 0) {
            body.innerHTML = '<tr><td colspan="4" class="text-center text-muted italic">個別オーバーライド設定はありません</td></tr>';
            return;
        }

        overrides.forEach(kv => {
            const tr = document.createElement('tr');
            const isShift = kv.key.startsWith('s_');
            const physKey = isShift ? kv.key.substring(2) : kv.key;

            tr.innerHTML = `
                <td><code class="font-mono">${physKey}</code></td>
                <td><span class="badge">${isShift ? 'Shift ON' : 'Shift OFF'}</span></td>
                <td><code class="font-mono">${kv.value}</code></td>
                <td>
                    <button class="btn danger btn-xs btn-delete-override">削除</button>
                </td>
            `;

            tr.querySelector('.btn-delete-override').addEventListener('click', () => {
                this.doc.deleteKey(section, kv.key);
                this.renderVisualKeyboard();
                this.renderLayoutOverridesTable();
                this.closeKeyEditor();
                this.markModified();
            });

            body.appendChild(tr);
        });
    },

    parseCombinationValue(val) {
        if (!val) return null;
        
        const parts = [];
        let inQuotes = false;
        let current = "";
        for (let i = 0; i < val.length; i++) {
            const char = val[i];
            if (char === '"') {
                inQuotes = !inQuotes;
                current += char;
            } else if (char === "," && !inQuotes) {
                parts.push(current.trim());
                current = "";
            } else {
                current += char;
            }
        }
        parts.push(current.trim());

        const processedParts = parts.map(part => {
            if (part.startsWith('"') && part.endsWith('"') && part.length >= 2) {
                return part.substring(1, part.length - 1);
            }
            return part;
        });

        if (processedParts.length === 0) {
            return null;
        }

        let mode = 7;
        let holdTh = null;
        let bTime = null;
        let startIdx = 1;

        const firstVal = processedParts[0];
        const modeParts = firstVal.split(',').map(p => p.trim());

        if (modeParts.length > 0 && /^\d+$/.test(modeParts[0])) {
            mode = parseInt(modeParts[0], 10);
            if (modeParts.length >= 2 && modeParts[1] !== "") {
                holdTh = parseInt(modeParts[1], 10);
            }
            if (modeParts.length >= 3 && modeParts[2] !== "") {
                bTime = parseInt(modeParts[2], 10);
            }
            startIdx = 2;
        } else {
            mode = 7;
            startIdx = 1;
        }

        const actions = [];
        for (let i = startIdx - 1; i < processedParts.length; i++) {
            actions.push(processedParts[i]);
        }

        return {
            mode: mode,
            holdTh: holdTh,
            bTime: bTime,
            action1: actions[0] || "",
            action2: actions[1] || "",
            action3: actions[2] || ""
        };
    },

    serializeCombinationValue(opts) {
        const { mode, holdTh, bTime, action1, action2, action3 } = opts;
        
        let modePart = mode.toString();
        const hasHoldTh = holdTh !== null && holdTh !== undefined && holdTh !== "";
        const hasBTime = bTime !== null && bTime !== undefined && bTime !== "";
        
        if (hasHoldTh || hasBTime) {
            modePart += "," + (hasHoldTh ? holdTh : "");
            if (hasBTime) {
                modePart += "," + bTime;
            }
            modePart = `"${modePart}"`;
        }
        
        const actions = [action1];
        if (action3 !== "" && action3 !== undefined && action3 !== null) {
            actions.push(action2 || "");
            actions.push(action3);
        } else if (action2 !== "" && action2 !== undefined && action2 !== null) {
            actions.push(action2);
        }
        
        return modePart + "," + actions.join(",");
    },

    renderCombinationsTable() {
        const body = document.getElementById('combinations-table-body');
        body.innerHTML = "";
        
        const section = this.activeLayoutSec;
        if (!section) return;

        const keys = this.doc.getKeys(section);
        const combinations = keys.filter(kv => kv.key.toLowerCase().startsWith('m_'));

        if (combinations.length === 0) {
            body.innerHTML = '<tr><td colspan="6" class="text-center text-muted italic">同時押し定義はありません</td></tr>';
            return;
        }

        combinations.forEach(kv => {
            const pair = kv.key.substring(2); 
            const parsed = this.parseCombinationValue(kv.value);
            
            let modeDisplay = "";
            if (parsed) {
                modeDisplay = `Mode ${parsed.mode}`;
                const hasHoldTh = parsed.holdTh !== null;
                const hasBTime = parsed.bTime !== null;
                if (hasHoldTh || hasBTime) {
                    modeDisplay += ` (${hasHoldTh ? parsed.holdTh + 'ms' : 'デフォルト'} / ${hasBTime ? parsed.bTime + 'ms' : 'デフォルト'})`;
                } else {
                    modeDisplay += " (デフォルト)";
                }
            } else {
                modeDisplay = "不正なフォーマット";
            }

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><code class="font-mono">${pair}</code></td>
                <td><span style="font-size: 0.85rem; color: var(--text-secondary);">${modeDisplay}</span></td>
                <td><code class="font-mono">${parsed ? parsed.action1 : kv.value}</code></td>
                <td><code class="font-mono">${parsed && parsed.action2 ? parsed.action2 : '-'}</code></td>
                <td><code class="font-mono">${parsed && parsed.action3 ? parsed.action3 : '-'}</code></td>
                <td>
                    <button class="btn danger btn-xs btn-delete-comb">削除</button>
                </td>
            `;

            tr.querySelector('.btn-delete-comb').addEventListener('click', () => {
                this.doc.deleteKey(section, kv.key);
                this.renderCombinationsTable();
                this.markModified();
            });

            body.appendChild(tr);
        });
    },

    createLayoutSectionFromTemplate(sectionName, template) {
        if (template === 'qwerty') {
            this.doc.setValue(sectionName, 'Mode', '1');
            this.doc.setValue(sectionName, 'L00', ' 1 2 3 4 5 6 7 8 9 0 - ^ \\');
            this.doc.setValue(sectionName, 'L01', ' q w e r t y u i o p @ [');
            this.doc.setValue(sectionName, 'L02', ' a s d f g h j k l ; : ]');
            this.doc.setValue(sectionName, 'L03', ' z x c v b n m , . / \\');
        } else if (template === 'fmix13') {
            this.doc.setValue(sectionName, 'Mode', '1');
            this.doc.setValue(sectionName, 'L00', ' 1 2 3 4 5 6 7 8 9 0 - ^ \\');
            this.doc.setValue(sectionName, 'L01', ' q w r l k y f u p ; @ [');
            this.doc.setValue(sectionName, 'L02', ' a s d t g h n e i o : ]');
            this.doc.setValue(sectionName, 'L03', ' z x c v b j m , . / \\');
        } else if (template === 'kanade') {
            this.doc.setValue(sectionName, 'Mode', '4');
            this.doc.setValue(sectionName, 'L00', ' 1 2 3 4 5 6 7  8 9  0 - ^ \\');
            this.doc.setValue(sectionName, 'L01', ' q w r p l f yu u yo - @ [');
            this.doc.setValue(sectionName, 'L02', ' k s t n h ; a  i e  o : ]');
            this.doc.setValue(sectionName, 'L03', ' g z d m b j m  , .  / \\');
            
            this.doc.setValue(sectionName, 'S00', ' 1 2 3 4 5 6 7   8  9  0 - ^ \\');
            this.doc.setValue(sectionName, 'S01', ' q w r p l f yu  u  yo - @ [');
            this.doc.setValue(sectionName, 'S02', ' k s t n h ; ya  xi xe o : ]');
            this.doc.setValue(sectionName, 'S03', ' [ ] d m b j ltu ,  .  / \\');
        }
    },

    /* ============================================================================
       MODIFIER LAYER MAP EDITOR
       ============================================================================ */
    loadLayerMap(layerName) {
        this.activeLayerName = layerName;
        document.getElementById('layer-title-name').innerHTML = `モディファイアレイヤー設定 <span>[${layerName}]</span>`;
        document.getElementById('layer-section-name-input').value = layerName;
        
        const body = document.getElementById('layer-maps-table-body');
        body.innerHTML = "";

        const keys = this.doc.getKeys(layerName);
        if (keys.length === 0) {
            body.innerHTML = '<tr><td colspan="3" class="text-center text-muted italic">キーマッピングが登録されていません。右のキーボードをクリックして追加してください。</td></tr>';
        } else {
            keys.forEach(kv => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><code class="font-mono">${getDispChar(kv.key)}</code></td>
                    <td><code class="font-mono">${kv.value}</code></td>
                    <td>
                        <button class="btn danger btn-xs btn-delete-layer-map">削除</button>
                    </td>
                `;

                tr.querySelector('.btn-delete-layer-map').addEventListener('click', () => {
                    this.doc.deleteKey(layerName, kv.key);
                    this.loadLayerMap(layerName);
                    this.markModified();
                });
                body.appendChild(tr);
            });
        }

        this.renderLayerVirtualKeyboard();
    },

    renderLayerVirtualKeyboard() {
        const kbd = document.getElementById('layer-virtual-keyboard');
        kbd.innerHTML = "";

        KEYBOARD_ROWS.forEach(row => {
            const rowDiv = document.createElement('div');
            rowDiv.className = `keyboard-row keyboard-row-${row.rowId}`;

            for (let i = row.range[0]; i <= row.range[1]; i++) {
                const physKey = QWERTY_CHARS[i];
                const entryName = getEntryName(physKey);
                
                const val = this.doc.getValue(this.activeLayerName, entryName, "");
                const isMapped = val !== "";

                const keycap = document.createElement('div');
                keycap.className = 'keycap';
                if (isMapped) {
                    keycap.classList.add('has-override');
                } else {
                    keycap.classList.add('is-empty');
                }

                const disp = isMapped ? val : physKey;
                const cleanDisp = disp.startsWith('{sc') ? getDispChar(disp.match(/^{sc[0-9A-Fa-f]+}$/) ? disp.slice(1, -1) : disp) : disp;

                keycap.innerHTML = `
                    <span class="key-physical">${physKey.toUpperCase()}</span>
                    <span class="key-mapped font-mono">${cleanDisp}</span>
                `;

                keycap.addEventListener('click', () => {
                    const newMapping = prompt(`物理キー "${physKey.toUpperCase()}" がこのレイヤーで送信する値を入力してください (空欄で削除):`, val);
                    if (newMapping !== null) {
                        if (newMapping.trim() === "") {
                            this.doc.deleteKey(this.activeLayerName, entryName);
                        } else {
                            this.doc.setValue(this.activeLayerName, entryName, newMapping);
                        }
                        this.loadLayerMap(this.activeLayerName);
                        this.markModified();
                    }
                });

                rowDiv.appendChild(keycap);
            }
            kbd.appendChild(rowDiv);
        });
    },

    /* ============================================================================
       PANEL SWITCHER
       ============================================================================ */
    switchPanel(panelId) {
        document.querySelectorAll('.content-panel').forEach(panel => {
            panel.classList.remove('active');
        });
        const activePanel = document.getElementById(panelId);
        if (activePanel) activePanel.classList.add('active');
        this.currentPanel = panelId;

        // Highlight matching sidebar item
        document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
        
        if (panelId === 'panel-settings') {
            const el = document.querySelector('.nav-item[data-panel="panel-settings"]');
            if (el) el.classList.add('active');
        } else if (panelId === 'panel-dynamic-layers') {
            const el = document.querySelector('.nav-item[data-panel="panel-dynamic-layers"]');
            if (el) el.classList.add('active');
        } else if (panelId === 'panel-raw') {
            const el = document.querySelector('.nav-item[data-panel="panel-raw"]');
            if (el) el.classList.add('active');
        } else if (panelId === 'panel-slot' && this.activeLayoutSlot) {
            const el = document.querySelector(`.nav-item[data-slot="${this.activeLayoutSlot}"]`);
            if (el) el.classList.add('active');
        } else if (panelId === 'panel-layout' && this.activeLayoutSec) {
            const el = document.querySelector(`.nav-item[data-layout="${this.activeLayoutSec}"]`);
            if (el) el.classList.add('active');
        } else if (panelId === 'panel-layer' && this.activeLayerName) {
            const el = document.querySelector(`.nav-item[data-layer="${this.activeLayerName}"]`);
            if (el) el.classList.add('active');
        }
    }
};

/* ============================================================================
   MODAL UTILITIES
   ============================================================================ */
function showModal(id) {
    const el = document.getElementById(id);
    if (el) {
        el.classList.add('show');
        const inputs = el.querySelectorAll('input[type="text"]');
        inputs.forEach(input => input.value = "");
    }
}

function closeModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove('show');
}

// Global window trigger initialization
window.addEventListener('DOMContentLoaded', () => {
    App.init();
});
