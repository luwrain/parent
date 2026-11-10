# EditArea Usage Analysis — org.luwrain.app.notepad

This document describes how the `EditArea` control (from `org.luwrain.controls.edit`)
is used in the notepad application (`base/app-notepad`, package `org.luwrain.app.notepad`).
It is intended as a reference for adding `EditArea` to other applications without
re-reading the notepad sources.

## 1. Overview

`EditArea` is the central multiline text editing control. It extends `NavigationArea`
and delegates the actual editing logic to a `MultilineEdit` instance. The notepad
application uses it as its single main editing area.

Key classes involved:

- `org.luwrain.controls.edit.EditArea` — the area itself.
- `org.luwrain.controls.edit.MultilineEdit` — the editing engine (handles input events).
- `org.luwrain.controls.edit.MultilineEditTranslator` — default `MultilineEdit.Model`
  implementation bridging `MutableMarkedLines` and `HotPointControl`.
- `org.luwrain.controls.edit.MultilineEditModelWrap` — base class for wrapping the model.
- `org.luwrain.controls.edit.DefaultEditAreaAppearance` — default appearance.
- `org.luwrain.controls.EditSpellChecking` — spell checking integration (from `io/io`).

## 2. Construction

`EditArea` is constructed with an `EditArea.Params` object. The notepad app builds
the params via the `LayoutBase.editParams(...)` helper (see `LayoutBase` in
`org.luwrain.app.base`), which pre-populates the `ControlContext`.

```java
this.editArea = new EditArea(editParams(p -> {
    p.name = "";
    p.appearance = new Appearance(getControlContext()) {
        @Override App.Mode getMode() { return app.mode; }
        @Override public EditArea getEditArea() { return editArea; }
    };
    p.changeListeners = List.of(modificationMarkListener);
    p.editFactory = pp -> {
        pp.model = new Indents(pp.model) {
            @Override App.Mode getMode() { return app.mode; }
            @Override public EditArea getEditArea() { return editArea; }
        };
        return new MultilineEdit(pp);
    };
})) {
    // anonymous subclass overriding onSystemEvent, onAreaQuery, getAreaName
};
```

### 2.1 `EditArea.Params` fields used

- `name` — area name (empty string here; overridden by `getAreaName()`).
- `appearance` — an `EditArea.Appearance` (extends `MultilineEdit.Appearance`).
- `changeListeners` — list of `EditArea.ChangeListener`.
- `editFactory` — an `EditArea.EditFactory` producing a custom `MultilineEdit`.

Note: `EditArea.Params` also has `content`, `inputEventListeners`, and `context`
fields, but notepad does not set `content` (defaults to `MutableMarkedLinesImpl`)
and does not set `inputEventListeners` (the `editParams` helper leaves the default
list from the `Params(ControlContext)` constructor, which installs two script-hook
listeners).

### 2.2 Custom appearance

Notepad subclasses `DefaultEditAreaAppearance` (in `Appearance.java`) to override
`announceLine(int index, String line)`. It selects the `SpeakableTextType` based on
the current `App.Mode` (NONE / NATURAL / PROGRAMMING) and, if the line has spell
problem marks, announces with the `Sounds.SPELLING` sound instead of the default.

The appearance is abstract with two abstract methods (`getMode()`, `getEditArea()`)
that the anonymous subclass implements by closing over `app` and `editArea`.

### 2.3 Custom edit factory / model wrapper

Notepad wraps the model with `Indents` (extends `MultilineEditModelWrap`). The
`editFactory` lambda receives `MultilineEdit.Params` (already containing
`context`, `model` = the translator, `appearance`, `regionPoint`), replaces
`pp.model` with the `Indents` wrapper, and returns a new `MultilineEdit(pp)`.

`Indents` is currently a thin wrapper (only declares abstract `getMode()` and
`getEditArea()`), demonstrating the extension point for customizing model behavior
(e.g. indentation) without modifying `MultilineEditTranslator`.

## 3. Change listeners

`EditArea.ChangeListener` has a single method:

```java
void onEditChange(EditArea editArea, MarkedLines lines, HotPoint hotPoint);
```

Notepad registers a `modificationMarkListener` that sets `app.modified = true`.

The spell checker `EditSpellChecking` also implements `EditArea.ChangeListener`
and is added/removed dynamically via `editArea.setChangeListeners(...)` when the
mode changes (see section 6).

## 4. Reading and writing text

- `editArea.getTextAsList()` — returns `List<String>` of all lines.
- `editArea.getText()` — returns `String[]`.
- `editArea.getText(String lineSeparator)` — joins lines with a separator.
- `editArea.getContent()` — returns the underlying `MutableMarkedLines`.
- `editArea.getHotPointX()` / `getHotPointY()` — cursor position.
- `editArea.setLine(int index, String line)` — set a single line.
- `editArea.setText(String[] lines)` — replace all content.
- `editArea.clear()` — clear content.

Notepad uses `getTextAsList()` when saving and for AI assist, and uses
`editArea.update(...)` (see below) for programmatic bulk modifications.

## 5. Programmatic updates — `editArea.update(...)`

`EditArea.update(EditUpdating)` is the recommended way to modify content
programmatically. The functional interface is:

```java
public interface EditUpdating {
    boolean editUpdate(MutableMarkedLines lines, HotPointControl hotPoint);
}
```

The lambda receives the mutable content (`MutableMarkedLines`) and the hot point
(`HotPointControl`, which `EditArea` itself implements). Return `true` to notify
change listeners, `false` to skip notification.

Examples from notepad:

```java
// Replace all occurrences (notify listeners)
editArea.update((lines, hotPoint) -> {
    for (int i = 0; i < lines.getLineCount(); i++)
        lines.setLine(i, lines.getLine(i).replaceAll(oldValue, newValue));
    return true;
});

// Set full text without notifying listeners
editArea.update((lines, hotPoint) -> {
    lines.setLines(text.toArray(new String[text.size()]));
    return false;
});
```

After a bulk update that returns `false`, notepad calls `editArea.refresh()` to
redraw and re-announce the area name.

## 6. Spell checking integration

`EditSpellChecking` (from `org.luwrain.controls`, in the `io/io` subproject)
implements `EditArea.ChangeListener`. It is constructed with a `Luwrain` instance
(defaults to Russian language).

Usage pattern in notepad:

- `spellChecking = new EditSpellChecking(getLuwrain());`
- Add as a change listener: `editArea.setChangeListeners(List.of(modificationMarkListener, spellChecking));`
- Initial full check: `spellChecking.initialChecking(editArea);`
- Remove marks: `spellChecking.eraseSpellingMarks(editArea);`
- Access checker: `spellChecking.getSpellChecker()` (for suggestions/exclusions).

The spell checker runs in the background (`luwrain.executeBkg`) and applies marks
via `editArea.update(...)` on the UI thread (`luwrain.runUiSafely`).

Notepad's `App.Mode` controls whether spell checking is active:
- `NONE` — no spell checking (only `modificationMarkListener`).
- `NATURAL` — spell checking active (`modificationMarkListener` + `spellChecking`).
- `PROGRAMMING` — no spell checking (marks erased).

## 7. Overriding EditArea methods

Notepad creates an anonymous `EditArea` subclass overriding:

- `onSystemEvent(SystemEvent)` — handles `SystemEvent.Code.SAVE` (calls `app.onSave()`)
  and `SystemEvent.Code.IDLE` (announces spell problem at cursor).
- `onAreaQuery(AreaQuery)` — answers `CurrentDirQuery` with the parent directory
  of the current file.
- `getAreaName()` — returns the file name or the initial title.

## 8. Integration with LayoutBase

`MainLayout` extends `LayoutBase` (from `org.luwrain.app.base`). The edit area is
integrated as follows:

- `setPropertiesHandler(editArea, a -> new SettingsLayout(app, getReturnAction()));`
  — ALT+ENTER opens the settings form.
- `setAreaLayout(editArea, actions(...));` — sets the edit area as the single area
  with a set of `ActionInfo` actions (replace, spell-right, word-suggestions,
  add-spell-exclusion, charset, AI assist, open, save-as, and three mode actions).

The `LayoutBase` automatically wraps the area in a protective shell and resolves
the control context to the wrapped area.

## 9. Actions (keyboard shortcuts)

Notepad registers these actions on the edit area (via `LayoutBase.action(...)`):

- `replace` — F5
- `spell-right` — SHIFT+ARROW_RIGHT
- `word-suggestions` — F8
- `add-spell-exclusion` — SHIFT+F8
- `charset` — F9
- `ai-assist` — F10
- `open` — SHIFT+F3
- `save-as` — SHIFT+F2
- `mode-none` — ALT+F1
- `mode-natural` — ALT+F2
- `mode-programming` — ALT+F3

## 10. Key API summary for reuse

To add `EditArea` to another application, the minimal steps are:

1. Create params via `LayoutBase.editParams(...)` (or manually with a `ControlContext`).
2. Set `params.name`, `params.appearance` (subclass `DefaultEditAreaAppearance` if
   custom line announcement is needed), and optionally `params.changeListeners`.
3. Optionally set `params.editFactory` to wrap the model (e.g. for indentation).
4. Construct `new EditArea(params)` (optionally subclass to override
   `onSystemEvent`, `onAreaQuery`, `getAreaName`).
5. Register a properties handler and set the area layout via `LayoutBase`.
6. Use `editArea.update(...)` for programmatic changes, `getTextAsList()` /
   `getText()` for reading, and `setChangeListeners(...)` to toggle listeners.

## 11. Important notes

- `EditArea` never reports zero lines: `getLineCount()` returns at least 1.
- `update(...)` returning `false` skips change-listener notification; call
  `refresh()` afterwards if a redraw/name announcement is needed.
- `EditArea` extends `NavigationArea`, so navigation (arrows, page up/down, etc.)
  is inherited; `MultilineEdit` handles character input, backspace, delete, tab,
  enter, and clipboard paste.
- The `EditArea.Params(ControlContext)` constructor installs two default
  `inputEventListeners` that run script hooks (`TEXT_INPUT_ML` and `TEXT_INPUT_SL`).
  These are present unless explicitly overridden.
- `EditSpellChecking` lives in `io/io` (package `org.luwrain.controls`), not in
  `core`, so applications using it must depend on the `io` subproject.
