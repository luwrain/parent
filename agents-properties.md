# Формы редактирования свойств (Property Layouts)

Этот файл собирает ключевые сведения о том, как в проекте LUWRAIN устроены
формы редактирования свойств сущностей. Обычно они находятся в подпакете
`layouts` конкретного приложения и называются по схеме
`<ИмяСущности>PropertiesLayout` (например, `GroupPropertiesLayout`,
`AccountPropertiesLayout`, `EventPropertiesLayout`, `TaskPropertiesLayout`).

Вся информация ниже собрана на реальных примерах из кода, чтобы в следующий
раз не приходилось читать много файлов заново.

## 1. Общая схема класса

Форма свойств — это `final class`, наследующий `org.luwrain.app.base.LayoutBase`.
Она не создаёт отдельный `ListArea`, а использует один `FormArea`:

```java
public final class TaskPropertiesLayout extends LayoutBase
{
    // Здесь обычно объявляются константы-идентификаторы полей
    // и ссылки на app, entity, formArea.
}
```

Канонический набор полей класса:

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

- `App` — класс приложения, наследник `AppBase<Strings>`.
- Сущность передаётся в конструктор и изменяется в `save()`.
- `formArea` часто остаётся `package-private` или `final`, если нужен доступ из
  внешнего кода.

## 2. Конструктор

Сигнатура почти всегда одинакова:

```java
public TaskPropertiesLayout(App app, Task task, ActionHandler closing)
{
    super(app);
    this.app = app;
    this.task = task;
    final var s = app.getStrings();

    this.formArea = new FormArea(getControlContext(),
        s.taskPropertiesAreaName(requireNonNullElse(task.getTitle(), "")));

    // добавление полей
    formArea.addEdit(TITLE, s.taskPropertiesTitle(), requireNonNullElse(task.getTitle(), ""));
    formArea.addEdit(DESCR, s.taskPropertiesDescr(), requireNonNullElse(task.getDescr(), ""));

    // если есть список значений — addList
    // если есть флаги — addCheckbox
    // если есть пароль — addPasswd
    // если есть большое текстовое поле — addMultilineEdit

    setCloseHandler(closing);
    setOkHandler(() -> {
        if (!save())
            return true;            // остаться в форме при ошибке
        app.getLuwrain().playSound(Sounds.DONE);
        return closing.onAction();
    });
    setAreaLayout(formArea, actions());
}
```

Важные моменты:

- `getControlContext()` даёт `ControlContext`, который корректно оборачивает
  область и защищает от исключений.
- Первый аргумент `FormArea` — название области (показывается пользователю).
  Название можно строить через строковый ресурс с аргументом, например
  `s.groupPropertiesAreaName(group.getName())` или
  `s.taskPropertiesAreaName(title)`.
- Все изначальные значения принято защищать через `requireNonNullElse`,
  чтобы не передать `null` в `FormArea`.
- `setAreaLayout(formArea, actions())` — `actions()` можно вызывать без
  аргументов, если отдельные действия не нужны. Допустимо и
  `setAreaLayout(formArea, null)`.
- `setCloseHandler(closing)` и `setOkHandler(...)` обязательны для корректной
  работы ESC и OK.

## 3. Порядок полей в обработчике OK

Стандартная структура `setOkHandler`:

```java
setOkHandler(() -> {
    if (!save())
        return true;               // не вышли из формы
    app.getLuwrain().playSound(Sounds.DONE);
    return closing.onAction();     // закрытие/возврат
});
```

Если `save()` вернул `false`, возвращается `true`, то есть событие обработано
и пользователь остаётся в форме, чтобы исправить ошибку.

Хорошая практика — подтверждать успешное сохранение звуком `Sounds.DONE`.

## 4. Метод save()

`save()` обычно `private boolean save(<Entity> entity)` или без аргументов,
если сущность хранится в поле. Порядок такой:

1. Прочитать значения полей.
2. Проверить обязательные значения.
3. При ошибке показать `app.message(...)` с `Luwrain.MessageType.ERROR` и
   вернуть `false`.
4. Установить значения в сущность.
5. Сохранить через DAO.
6. Вернуть `true`.

Пример проверки обязательного названия:

```java
final String title = formArea.getEnteredText(TITLE).trim();
if (title.isEmpty())
{
    app.message(s.taskPropertiesTitleCannotBeEmpty(),
                Luwrain.MessageType.ERROR);
    return false;
}
```

Пример сохранения:

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

### Чтение значений из FormArea

| Тип поля | Добавление | Чтение |
|---|---|---|
| обычный однострочный текст | `addEdit(NAME, caption, initial)` | `getEnteredText(NAME)` |
| пароль | `addPasswd(NAME, caption, initial, null, true)` | `getEnteredText(NAME)` |
| список | `addList(NAME, caption, initial, listChoosing, null, true)` | `getSelectedListItem(NAME)` |
| флажок | `addCheckbox(NAME, caption, initialState)` | `getCheckboxState(NAME)` |
| многострочный текст | `addMultilineEdit(caption, List<String>, enabled)` | `getMultilineEditText()` |
| статичный текст | `addStatic(NAME, caption)` | обычно не читается |

## 5. Детали использования FormArea

`FormArea` находится в `org.luwrain.controls`.

### 5.1. Текстовое поле

Конструктор и подписи:

```java
formArea.addEdit(NAME, caption);
formArea.addEdit(NAME, caption, initialText);
formArea.addEdit(NAME, caption, initialText, obj, enabled);
```

Пример:

```java
formArea.addEdit(TITLE, s.taskPropertiesTitle(), requireNonNullElse(task.getTitle(), ""));
```

### 5.2. Пароль

```java
formArea.addPasswd(PASSWD, s.accountPropertiesPasswd(),
                   requireNonNullElse(account.getPasswd(), ""), null, true);
```

Последние два аргумента — `Object obj` и `boolean enabled`.

### 5.3. Флажок

Две часто используемые перегрузки:

```java
formArea.addCheckbox(NAME, caption, initialState);
formArea.addCheckbox(NAME, caption, initialState, obj, enabled);
```

Чтение:

```java
boolean value = formArea.getCheckboxState(NAME);
```

Пример из `Pop3AccountLayout`:

```java
formArea.addCheckbox(SSL, s.accountPropertiesSsl(), account.isSsl());
...
account.setSsl(formArea.getCheckboxState(SSL));
```

### 5.4. Список значений

Сигнатура:

```java
formArea.addList(NAME, caption, initialSelectedItem, listChoosing, obj, enabled);
```

- `initialSelectedItem` — объект, выбранный по умолчанию.
- `listChoosing` — реализация `FormArea.ListChoosing`.
- Выбранный объект можно получить через `getSelectedListItem(NAME)` и
  привести к нужному типу.

Простой способ показать список значений — использовать готовый
`FormUtils.FixedListChoosing` из `org.luwrain.controls.FormUtils`:

```java
formArea.addList(STATUS, caption, Task.Status.NEW,
    new FormUtils.FixedListChoosing(getLuwrain(), caption,
        Task.Status.values(), Popups.DEFAULT_POPUP_FLAGS),
    null, true);
```

Либо реализовать выбор вручную через `Popups.fixedList`:

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

`Popups.fixedList` импортируется из `org.luwrain.popups.Popups`.

### 5.5. Многострочное поле

Многострочное поле в `FormArea` может быть только одно и всегда располагается
внизу формы. Добавляется так:

```java
List<String> urls = new ArrayList<>(...);
urls.add("");
formArea.addMultilineEdit(s.groupPropertiesUrls(), urls, true);
```

Третий аргумент — `boolean enabled`.

Чтение содержимого:

```java
String[] lines = formArea.getMultilineEditText();
```

Возвращается массив строк. Если поле не активировано, возвращается пустой
массив. Это удобно для превращения строк в список:

```java
group.setUrls(Arrays.stream(lines)
    .map(String::trim)
    .filter(e -> !e.isEmpty())
    .toList());
```

Для строки целиком используйте:

```java
String joined = String.join("\n", lines);
```

### 5.6. Статичный текст

Если нужно показать нередактируемое значение:

```java
formArea.addStatic(NAME, caption);
formArea.addStatic(NAME, caption, obj);
```

## 6. Валидация чисел и дат

### 6.1. Целые числа

Проверка обычно строится так:

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

Для порта из `Pop3AccountLayout` дополнительно проверяется диапазон:

```java
if (portValue <= 0 || portValue > 65536) { ... return false; }
```

### 6.2. Даты

В `EventPropertiesLayout` используется `SimpleDateFormat`:

```java
static private final SimpleDateFormat DATE_FORMAT =
    new SimpleDateFormat("dd.MM.yyyy");
static private final SimpleDateFormat TIME_FORMAT =
    new SimpleDateFormat("HH:mm");
```

Значение показывается в текстовых полях и разбирается при сохранении:

```java
try {
    final var datePart = DATE_FORMAT.parse(form.getEnteredText(DATE).trim());
    final var timePart = TIME_FORMAT.parse(form.getEnteredText(TIME).trim());
    event.setDtStart(...);
}
catch (ParseException e)
{
    // либо показать ошибку, либо проигнорировать
}
```

Если поле необязательное, пустое значение можно трактовать особым образом:

```java
private long parseDue(String value) throws ParseException
{
    final String v = value.trim();
    if (v.isEmpty())
        return -1L;
    return DUE_FORMAT.parse(v).getTime();
}
```

## 7. Работа с многострочными строками-коллекциями

Частая особенность — сущность хранит коллекцию, а в форме она
редактируется как многострочное поле. См. `GroupPropertiesLayout`:

```java
List<String> urls = requireNonNullElse(group.getUrls(), Arrays.asList());
urls = new ArrayList<>(urls.stream()
    .map(e -> e.trim())
    .filter(e -> !e.isEmpty())
    .toList());
urls.add("");  // пустая строка для ввода нового значения
formArea.addMultilineEdit(s.groupPropertiesUrls(), urls, true);
```

При сохранении:

```java
final var urls = Arrays.asList(formArea.getMultilineEditText());
group.setUrls(urls.stream()
    .map(String::trim)
    .filter(e -> !e.isEmpty())
    .toList());
```

## 8. Списки значений из перечислений

Если у сущности есть `enum`, удобно всему перечислению давать
`toString()`-значения и передавать `values()` в список. Примеры из проекта:
`Task.Status`, `Task.Priority`, `Account.Type`.

Если нужно отображать локализованные подписи, а не технические имена, стоит
писать отдельный адаптер выбора; но в существующем коде чаще всего
используют сами enum-значения.

## 9. Строки (i18n)

Строки форм объявляются в интерфейсе `Strings` пакета приложения:

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

Далее они заполняются в:

- `src/main/resources/org/luwrain/app/<приложение>/Strings-en.properties`
- `src/main/resources/org/luwrain/app/<приложение>/Strings-ru.properties`

Пример с параметром:

```properties
TaskPropertiesAreaName = Properties of the "$1" task
```

Правила именования строк формы:

- `<форма>AreaName` — название области.
- `<форма><Поле>` — подпись поля.
- `<форма><Поле>CannotBeEmpty` — ошибка пустого обязательного поля.
- `<форма>Invalid<Поле>` — ошибка неверного формата поля.

## 10. Сохранение сущностей

Способ сохранения зависит от источника данных:

- Новости: `app.persist.getGroupDAO().update(group)`.
- Задачи: `app.persist.getTaskDAO().update(task)`.
- Почта: `app.getData().accountDAO.update(account)`.
- Конфигурация (в `OptionsLayout`): изменение POJO и затем
  `app.getLuwrain().saveConf(app.conf)`.

Если добавление/удаление не требуется, в форме обычно используют только
`update`. Если форма создаёт новый объект, используйте `add(...)`:

```java
app.persist.getGroupDAO().add(group);
```

## 11. Стиль и соглашения

- Заголовок файла:

```java
// SPDX-License-Identifier: BUSL-1.1
// Copyright 2012-2026 Michael Pozhidaev <msp@luwrain.org>
```

- Открывающая фигурная скобка всегда на новой строке.
- Комментарии и Javadoc — только на английском.
- Для проверки параметров используйте `NullCheck.*` и
  `java.util.Objects.requireNonNull`.
- Для подстраховки от `null` при чтении значений сущности —
  `requireNonNullElse`.
- Статический импорт:

```java
import static java.util.Objects.*;
```

- Поля форм и имена элементов принято хранить в `static private final String`.
- Формы свойств почти всегда помещаются в пакет `layouts` приложения.

## 12. Минимальный шаблон

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

## 13. Ссылки на типовые примеры в проекте

- `pim/app-news/src/main/java/org/luwrain/app/news/layouts/GroupPropertiesLayout.java`
  — хорошая форма с текстовыми полями, проверкой числа и многострочным
  списком URL.
- `pim/app-mail/src/main/java/org/luwrain/app/mail/layouts/Pop3AccountLayout.java`
  — текстовые поля, пароль, несколько флажков, проверка порта.
- `pim/app-diary/src/main/java/org/luwrain/app/diary/layouts/EventPropertiesLayout.java`
  — работа с датой и временем через `SimpleDateFormat`.
- `base/player/src/main/java/org/luwrain/app/player/layouts/DirAlbumPropertiesLayout.java`
  — простейшая форма с текстовыми полями и флажками.
- `io/app-github/src/main/java/org/luwrain/app/github/layouts/AccountPropertiesLayout.java`
  — форма с проверкой обязательного имени и тремя полями.

