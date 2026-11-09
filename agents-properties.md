# Property Layouts (Properties Editing Forms)

This file gathers the key information about how LUWRAIN property editing
forms are structured. They usually live in the `layouts` subpackage of a
particular application and are named according to the pattern
`<EntityName>PropertiesLayout` (for example, `GroupPropertiesLayout`,
`AccountPropertiesLayout`, `EventPropertiesLayout`, `TaskPropertiesLayout`).

All of the information below is collected from real examples in the code, so
that next time there is no need to re-read many files.

## 1. General class layout

A property form is a `final class` extending
`org.luwrain.app.base.LayoutBase`. It does not create a separate `ListArea`;
instead it uses a single `FormArea`:

```java
public final class TaskPropertiesLayout extends LayoutBase
{
    // Constants identifying fields are usually declared here,
    // as well as references to app, entity and formArea.
}
```

The canonical set of class fields is:

```java
static private final String
    TITLE = "title",
    DESCR = "descr",
    ...
    TAGS = "tags";

private final App app;
private final Task task;
final FormArea formArea;
```

- `App` is the application class, a subclass of `AppBase<Strings>`.
- The entity is passed into the constructor and modified in `save()`.
- `formArea` is often `package-private` or `final` when external access is
  needed.

## 2. Constructor

The signature is almost always the same:

```java
public TaskPropertiesLayout(App app, Task task, ActionHandler closing)
{
    super(app);
    this.app = app;
    this.task = task;
    final var s = app.getStrings();

    this.formArea = new FormArea(getControlContext(),
        s.taskPropertiesAreaName(requireNonNullElse(task.getTitle(), "")));

    // Add fields here
    formArea.addEdit(TITLE, s.taskPropertiesTitle(), requireNonNullElse(task.getTitle(), ""));
    formArea.addEdit(DESCR, s.taskPropertiesDescr(), requireNonNullElse(task.getDescr(), ""));

    // If a value list is needed, use addList
    // If flags are needed, use addCheckbox
    // If a password is needed, use addPasswd
    // If a large text block is needed, use addMultilineEdit

    setCloseHandler(closing);
    setOkHandler(() -> {
        if (!save())
            return true;            // stay in the form on error
        app.getLuwrain().playSound(Sounds.DONE);
        return closing.onAction();
    });
    setAreaLayout(formArea, actions());
}
```

Important points:

- `getControlContext()` returns a `ControlContext` that correctly wraps the
  area and protects it from exceptions.
- The first `FormArea` argument is the area name shown to the user. It can be
  built from a string resource with an argument, for example
  `s.groupPropertiesAreaName(group.getName())` or
  `s.taskPropertiesAreaName(title)`.
- Initial values are normally guarded with `requireNonNullElse` to avoid
  passing `null` into `FormArea`.
- `setAreaLayout(formArea, actions())` can take `actions()` with no arguments
  if no individual actions are needed. `setAreaLayout(formArea, null)` is
  also valid.
- `setCloseHandler(closing)` and `setOkHandler(...)` are required for correct
  ESC and OK handling.

## 3. Field order in the OK handler

The standard structure of `setOkHandler` is:

```java
setOkHandler(() -> {
    if (!save())
        return true;               // do not leave the form
    app.getLuwrain().playSound(Sounds.DONE);
    return closing.onAction();     // close/return
});
```

If `save()` returned `false`, return `true`, meaning that the event is handled
and the user stays in the form to fix the error.

It is good practice to confirm a successful save with the `Sounds.DONE` sound.

## 4. The save() method

`save()` is usually `private boolean save(<Entity> entity)` or has no
arguments when the entity is stored in a field. The order is:

1. Read the field values.
2. Validate required values.
3. On error, call `app.message(...)` with `Luwrain.MessageType.ERROR` and
   return `false`.
4. Assign values to the entity.
5. Save via the DAO.
6. Return `true`.

Example of validating a required name:

```java
final String title = formArea.getEnteredText(TITLE).trim();
if (title.isEmpty())
{
    app.message(s.taskPropertiesTitleCannotBeEmpty(),
                Luwrain.MessageType.ERROR);
    return false;
}
```

Example of saving:

```java
task.setTitle(title);
task.setDescr(formArea.getEnteredText(DESCR).trim());
task.setDueTimestamp(due);
task.setStatus((Task.Status) formArea.getSelectedListItem(STATUS));
task.setPriority((Task.Priority) formArea.getSelectedListItem(PRIORITY));
task.setTags(parseTags(formArea.getEnteredText(TAGS)));
task.setContent(String.join("\n", formArea.getMultilineEditText()));
app.persist.getTaskDAO().update(task);
return true;
```

### Reading values from FormArea

| Field type | Add method | Reading method |
|---|---|---|
| plain single-line text | `addEdit(NAME, caption, initial)` | `getEnteredText(NAME)` |
| password | `addPasswd(NAME, caption, initial, null, true)` | `getEnteredText(NAME)` |
| list | `addList(NAME, caption, initial, listChoosing, null, true)` | `getSelectedListItem(NAME)` |
| checkbox | `addCheckbox(NAME, caption, initialState)` | `getCheckboxState(NAME)` |
| multiline text | `addMultilineEdit(caption, List<String>, enabled)` | `getMultilineEditText()` |
| static text | `addStatic(NAME, caption)` | normally not read |

## 5. Details of using FormArea

`FormArea` is in `org.luwrain.controls`.

### 5.1. Text field

Constructor and signatures:

```java
formArea.addEdit(NAME, caption);
formArea.addEdit(NAME, caption, initialText);
formArea.addEdit(NAME, caption, initialText, obj, enabled);
```

Example:

```java
formArea.addEdit(TITLE, s.taskPropertiesTitle(), requireNonNullElse(task.getTitle(), ""));
```

### 5.2. Password

```java
formArea.addPasswd(PASSWD, s.accountPropertiesPasswd(),
                   requireNonNullElse(account.getPasswd(), ""), null, true);
```

The last two arguments are `Object obj` and `boolean enabled`.

### 5.3. Checkbox

Two commonly used overloads:

```java
formArea.addCheckbox(NAME, caption, initialState);
formArea.addCheckbox(NAME, caption, initialState, obj, enabled);
```

Reading:

```java
boolean value = formArea.getCheckboxState(NAME);
```

Example from `Pop3AccountLayout`:

```java
formArea.addCheckbox(SSL, s.accountPropertiesSsl(), account.isSsl());
...
account.setSsl(formArea.getCheckboxState(SSL));
```

### 5.4. Value list

Signature:

```java
formArea.addList(NAME, caption, initialSelectedItem, listChoosing, obj, enabled);
```

- `initialSelectedItem` is the object selected by default.
- `listChoosing` is an implementation of `FormArea.ListChoosing`.
- The selected object can be retrieved via `getSelectedListItem(NAME)` and
  cast to the required type.

A simple way to show a value list is to use the ready-made
`FormUtils.FixedListChoosing` from `org.luwrain.controls.FormUtils`:

```java
formArea.addList(STATUS, caption, Task.Status.NEW,
    new FormUtils.FixedListChoosing(getLuwrain(), caption,
        Task.Status.values(), Popups.DEFAULT_POPUP_FLAGS),
    null, true);
```

Alternatively, implement the selection manually via `Popups.fixedList`:

```java
formArea.addList(STATUS, s.taskPropertiesStatus(),
    requireNonNullElse(task.getStatus(), Task.Status.NEW),
    (area, itemName, current) -> chooseStatus(),
    null, true);

private Task.Status chooseStatus()
{
    final var selected = Popups.fixedList(getLuwrain(),
        app.getStrings().taskPropertiesStatus(),
        Task.Status.values(),
        Popups.DEFAULT_POPUP_FLAGS);
    return selected != null ? (Task.Status)selected
                            : requireNonNullElse(task.getStatus(), Task.Status.NEW);
}
```

`Popups.fixedList` is imported from `org.luwrain.popups.Popups`.

### 5.5. Multiline field

A `FormArea` can have only one multiline field, and it is always placed at the
bottom of the form. It is added like this:

```java
List<String> urls = new ArrayList<>(...);
urls.add("");
formArea.addMultilineEdit(s.groupPropertiesUrls(), urls, true);
```

The third argument is `boolean enabled`.

Reading the content:

```java
String[] lines = formArea.getMultilineEditText();
```

This returns an array of strings. If the field is not activated, it returns an
empty array. This is convenient for converting lines into a list:

```java
group.setUrls(Arrays.stream(lines)
    .map(String::trim)
    .filter(e -> !e.isEmpty())
    .toList());
```

To get the whole string as one value, use:

```java
String joined = String.join("\n", lines);
```

### 5.6. Static text

To display a non-editable value:

```java
formArea.addStatic(NAME, caption);
formArea.addStatic(NAME, caption, obj);
```

## 6. Validating numbers and dates

### 6.1. Integer numbers

Validation is usually built like this:

```java
final int orderIndexValue;
try {
    orderIndexValue = Integer.parseInt(orderIndex.trim());
}
catch (NumberFormatException e)
{
    app.message(s.groupPropertiesInvalidOrderIndex(),
                Luwrain.MessageType.ERROR);
    return false;
}
if (orderIndexValue < 0)
{
    app.message(s.groupPropertiesInvalidOrderIndex(),
                Luwrain.MessageType.ERROR);
    return false;
}
```

For a port, `Pop3AccountLayout` additionally checks the range:

```java
if (portValue <= 0 || portValue > 65536) { ... return false; }
```

### 6.2. Dates

`EventPropertiesLayout` uses `SimpleDateFormat`:

```java
static private final SimpleDateFormat DATE_FORMAT =
    new SimpleDateFormat("dd.MM.yyyy");
static private final SimpleDateFormat TIME_FORMAT =
    new SimpleDateFormat("HH:mm");
```

The value is shown in text fields and parsed when saving:

```java
try {
    final var datePart = DATE_FORMAT.parse(form.getEnteredText(DATE).trim());
    final var timePart = TIME_FORMAT.parse(form.getEnteredText(TIME).trim());
    event.setDtStart(...);
}
catch (ParseException e)
{
    // either show an error or ignore it
}
```

If the field is optional, an empty value can be handled specially:

```java
private long parseDue(String value) throws ParseException
{
    final String v = value.trim();
    if (v.isEmpty())
        return -1L;
    return DUE_FORMAT.parse(v).getTime();
}
```

## 7. Working with multiline string collections

A frequent pattern is that an entity stores a collection, while the form edits
it as a multiline field. See `GroupPropertiesLayout`:

```java
List<String> urls = requireNonNullElse(group.getUrls(), Arrays.asList());
urls = new ArrayList<>(urls.stream()
    .map(e -> e.trim())
    .filter(e -> !e.isEmpty())
    .toList());
urls.add("");  // empty line for entering a new value
formArea.addMultilineEdit(s.groupPropertiesUrls(), urls, true);
```

When saving:

```java
final var urls = Arrays.asList(formArea.getMultilineEditText());
group.setUrls(urls.stream()
    .map(String::trim)
    .filter(e -> !e.isEmpty())
    .toList());
```

## 8. Value lists from enums

If the entity has an `enum`, it is convenient to pass `values()` to a list.
Examples from the project: `Task.Status`, `Task.Priority`, `Account.Type`.

If localized labels are required rather than technical names, a custom
selection adapter should be written; however, existing code most often uses
the enum values themselves.

## 9. Strings (i18n)

Form strings are declared in the `Strings` interface of the application
package:

```java
@ResourceStrings(langs = { "en", "ru" })
public interface Strings
{
    String taskPropertiesAreaName(String title);
    String taskPropertiesTitle();
    String taskPropertiesDescr();
    String taskPropertiesDueDate();
    String taskPropertiesStatus();
    String taskPropertiesPriority();
    String taskPropertiesTags();
    String taskPropertiesContent();
    String taskPropertiesTitleCannotBeEmpty();
    String taskPropertiesInvalidDueDate();
}
```

They are then filled in:

- `src/main/resources/org/luwrain/app/<application>/Strings-en.properties`
- `src/main/resources/org/luwrain/app/<application>/Strings-ru.properties`

Example with a parameter:

```properties
TaskPropertiesAreaName = Properties of the "$1" task
```

Naming conventions for form strings:

- `<form>AreaName` — the area name.
- `<form><Field>` — the field caption.
- `<form><Field>CannotBeEmpty` — an error for an empty required field.
- `<form>Invalid<Field>` — an error for an invalid field format.

## 10. Saving entities

The saving method depends on the data source:

- News: `app.persist.getGroupDAO().update(group)`.
- Tasks: `app.persist.getTaskDAO().update(task)`.
- Mail: `app.getData().accountDAO.update(account)`.
- Configuration (in `OptionsLayout`): modify the POJO and then call
  `app.getLuwrain().saveConf(app.conf)`.

If adding/deleting is not needed, the form usually uses only `update`. If the
form creates a new object, use `add(...)`:

```java
app.persist.getGroupDAO().add(group);
```

## 11. Style and conventions

- File header:

```java
// SPDX-License-Identifier: BUSL-1.1
// Copyright 2012-2026 Michael Pozhidaev <msp@luwrain.org>
```

- Opening curly braces are always on a new line.
- Comments and Javadoc are in English only.
- Use `NullCheck.*` and `java.util.Objects.requireNonNull` for parameter
  validation.
- Use `requireNonNullElse` as a safety net when reading entity values.
- Static import:

```java
import static java.util.Objects.*;
```

- Field and element names are normally kept in `static private final String`.
- Property forms almost always live in the `layouts` package of the
  application.

## 12. Minimal template

```java
package org.luwrain.app.<app>.layouts;

import java.util.*;

import org.luwrain.core.*;
import org.luwrain.controls.*;
import org.luwrain.app.base.*;
import org.luwrain.app.<app>.*;

import static java.util.Objects.*;

public final class <Entity>PropertiesLayout extends LayoutBase
{
    static private final String NAME = "name";

    private final App app;
    private final <Entity> entity;
    final FormArea formArea;

    public <Entity>PropertiesLayout(App app, <Entity> entity, ActionHandler closing)
    {
        super(app);
        this.app = app;
        this.entity = entity;
        final var s = app.getStrings();
        this.formArea = new FormArea(getControlContext(),
            s.<entity>PropertiesAreaName(requireNonNullElse(entity.getName(), "")));
        formArea.addEdit(NAME, s.<entity>PropertiesName(), requireNonNullElse(entity.getName(), ""));
        setCloseHandler(closing);
        setOkHandler(() -> {
            if (!save())
                return true;
            app.getLuwrain().playSound(Sounds.DONE);
            return closing.onAction();
        });
        setAreaLayout(formArea, actions());
    }

    private boolean save()
    {
        final String name = formArea.getEnteredText(NAME).trim();
        if (name.isEmpty())
        {
            app.message(app.getStrings().<entity>PropertiesNameCannotBeEmpty(),
                        Luwrain.MessageType.ERROR);
            return false;
        }
        entity.setName(name);
        app.<...>.<dao>.update(entity);
        return true;
    }
}
```

## 13. References to typical examples in the project

- `pim/app-news/src/main/java/org/luwrain/app/news/layouts/GroupPropertiesLayout.java`
  — a good form with text fields, number validation, and a multiline URL list.
- `pim/app-mail/src/main/java/org/luwrain/app/mail/layouts/Pop3AccountLayout.java`
  — text fields, a password, several checkboxes, port validation.
- `pim/app-diary/src/main/java/org/luwrain/app/diary/layouts/EventPropertiesLayout.java`
  — date and time handling via `SimpleDateFormat`.
- `base/player/src/main/java/org/luwrain/app/player/layouts/DirAlbumPropertiesLayout.java`
  — a very simple form with text fields and checkboxes.
- `io/app-github/src/main/java/org/luwrain/app/github/layouts/AccountPropertiesLayout.java`
  — a form with a required-name check and three fields.

