# The LUWRAIN Project — Agent Instructions

## Project Overview

LUWRAIN is a platform for developing Java applications for people with visual impairments. It provides a text-based environment with speech synthesis, braille support, and sound feedback, but it isn't a screen reader. The project is split into multiple subprojects, each compiled into a separate JAR file.

The root project is a Gradle multi-module project (`settings.gradle`). The root `build.gradle` defines common configuration, dependency versions, and distribution tasks.

## Build System

- Build tool: Gradle with `build.gradle` and `settings.gradle`
- Java version: 17
- Encoding: UTF-8
- All Javadoc and code comments must be written in English
- Opening curly braces go on a new line
- Use `NullCheck.notNull`, `NullCheck.notEmpty`, `NullCheck.notNullItems` for parameter validation
- Use `java.util.Objects.requireNonNull` for non-null checks

## Project Structure

### Core Subproject (`core/`)

The central subproject. Builds `luwrain.jar`. Contains the package `org.luwrain.core` — the most central package.

Key source root: `core/src/main/java/`

#### Central Package: `org.luwrain.core`

Key interfaces and classes:

- `Luwrain` — the main facade interface for applications. Provides methods for speech, sound, configuration, area management, event handling, application launching, clipboard, braille, etc. Each application/extension gets its own instance.
- `Core` — the main implementation class (package-private). Manages the event loop, application lifecycle, speech, interaction, extensions, etc.
- `Application` — interface for all LUWRAIN applications. Key methods: `onLaunchApp(Luwrain)`, `getAreaLayout()`, `getAppName()`, `onAppClose()`.
- `MonoApp` — extends `Application` for apps that allow only one running instance.
- `Area` — fundamental UI entity. Extends `Lines` and `HotPoint`. Represents any interactive working object (text editor, table, tree, form, etc.). Key methods: `getAreaName()`, `getLineCount()`, `getLine(int)`, `getHotPointX/Y()`, `onInputEvent(InputEvent)`, `onSystemEvent(SystemEvent)`, `onAreaQuery(AreaQuery)`, `getAreaActions()`.
- `Extension` — interface for LUWRAIN extensions. Key methods: `init(Luwrain)`, `getCommands(Luwrain)`, `getExtObjects(Luwrain)`, `i18nExtension(Luwrain, I18nExtension)`, `getControlPanelFactories(Luwrain)`, `getUniRefProcs(Luwrain)`, `close()`.
- `Interaction` — interface for screen rendering and input. Manages drawing, font size, hot point visualization.
- `Speech` — speech synthesis management. Loads speech engines, manages channels, pitch, rate.
- `Event` / `InputEvent` / `SystemEvent` — event classes in `org.luwrain.core.events`.
- `EventResponse` — response to events, in `org.luwrain.core.events.resp`.
- `AreaLayout` — describes the layout of areas on screen.
- `AreaQuery` — queries from the core to areas.
- `Command` — command interface.
- `Shortcut` — application shortcut interface.
- `Popup` — popup interface.
- `Registry` — persistent key-value storage.
- `Braille` — braille output interface.
- `Clipboard` — clipboard interface.
- `UniRefProc` — universal reference processor.
- `Job` / `JobLauncher` — background job management.
- `PropertiesBase` / `PropertiesProvider` — configuration properties.
- `Config` / `Configs` — configuration management.
- `Launch` / `LauncherImpl` / `Starter` — application launching.
- `Base` — base class with stop conditions.
- `EventDispatching` — event dispatching logic.
- `WindowManager` — window/area layout management.
- `Tiles` / `TilesManager` — tile-based area arrangement.
- `AppManager` / `Apps` — application lifecycle management.
- `ExtensionsManager` — extension loading and management.
- `InterfaceManager` — Luwrain interface object management.
- `CommandManager` — command registration and execution.
- `UniRefProcManager` — UniRef processor management.
- `ObjRegistry` — object registry (shortcuts, commands, etc.).
- `EventQueue` — event queue.
- `GlobalKeys` — global keyboard shortcuts.
- `FileTypes` — file type associations.
- `Sounds` — sound identifiers enum.
- `BkgSounds` — background sounds.
- `WavePlayers` — WAV file playback.
- `MediaResourcePlayer` — media resource player interface.
- `FileFetcher` — file fetching interface.
- `ScriptFile` / `ScriptSource` / `ScriptText` — scripting support.
- `HookContainer` / `Hooks` — hook system.
- `OperatingSystem` — OS abstraction interface.
- `InitResult` — application initialization result.
- `Desktop` — desktop application interface.
- `WorkersTracking` — worker tracking.
- `Suggestions` — suggestion interface.
- `Search` — search interface.
- `Lines` / `MutableLines` / `MarkedLines` / `MutableMarkedLines` — line content interfaces.
- `HotPoint` / `HotPointControl` — hot point interfaces.
- `LineMarks` — line marking.
- `AreaLayoutHelper` / `AreaLayoutSwitch` — area layout utilities.
- `AreaWrapperFactory` — area wrapper factory.
- `AreaScriptAttr` — area script attributes.
- `AreaText` — area text extraction.
- `Areas` — area utilities.
- `ListenableArea` — listenable area interface.
- `listening/Listening` — area listening implementation.
- `EmptyExtension` / `EmptyJob` / `EmptyJobListener` / `EmptyFileFetching` — empty/default implementations.
- `SimpleShortcutCommand` / `DefaultShortcut` / `DefaultStarter` / `DefaultEventResponse` — default implementations.
- `SimpleObjFactory` / `ObjFactory` — object factories.
- `ErrorJobInstance` — error job wrapper.
- `TempFiles` — temporary file management.
- `CmdLine` — command line parsing.
- `Args` — command line arguments.
- `Log` — logging.
- `JniLoader` — JNI library loader.
- `Standalone` — standalone mode support.
- `Keyboard` — keyboard handling.
- `BrailleImpl` — braille implementation.
- `LuwrainImpl` — Luwrain interface implementation.
- `OpenedArea` / `OpenedPopup` — opened area/popup tracking.
- `LaunchedApp` / `LaunchedAppPopups` — launched app tracking.
- `Tile` / `TileVisitor` — tile visitor pattern.
- `HelpSections` — help sections.
- `Settings` — settings inner classes.
- `ConfigUpdate` — configuration update functional interface.
- `roles/Role` / `roles/TextEditor` — role interfaces.
- `util/Checks` / `util/UserProfile` / `util/RegistryExtractor` — utilities.

#### Sub-packages of `org.luwrain.core`:

- `org.luwrain.core.events` — event classes: `InputEvent`, `SystemEvent`, `ActionEvent`, `UpdateEvent`, `MoveHotPointEvent`, `ListeningFinishedEvent`
- `org.luwrain.core.events.resp` — event responses: `Base`, `TextResponse`, `LetterResponse`, `TreeItemResponse`, `HintResponse`, `ListItemResponse`
- `org.luwrain.core.queries` — area queries: `CurrentDirQuery`, `UniRefAreaQuery`, `BeginListeningQuery`, `UrlHotPointQuery`, `UrlAreaQuery`, `RegionTextQuery`, `BackgroundSoundQuery`, `UniRefHotPointQuery`
- `org.luwrain.core.sound` — sound management: `Manager`, `Config`, `Icons`, `BkgPlayer`
- `org.luwrain.core.speech` — speech utilities: `SpeakingText`, `EventResponseSpeech`, `SpeakingHook`
- `org.luwrain.core.listening` — listening: `Listening`, `CompatArea`, `PlainArea`
- `org.luwrain.core.annotations` — annotations (in `base/base`): `ResourceStrings`, `AppNoArgs`

#### Other Key Packages in Core:

- `org.luwrain.controls` — UI controls: `ListArea`, `TreeArea`, `TableArea`, `EditArea`, `ConsoleArea`, `CommanderArea`, `FormArea`, `CalendarArea`, `WizardArea`, `NavigationArea`, `SingleLineEdit`, `MultilineEdit`, `MarkableListArea`, `EditableListArea`, `TreeListArea`, `MessageArea`, `CenteredArea`, `SimpleArea`, `EmbeddedEdit`, `EmbeddedEditLines`, `SpellCheckingEditArea`, `FormSpellChecking`, `EditSpellChecking`, and related models, appearances, translators, correctors
- `org.luwrain.popups` — popup dialogs: `ListPopup`, `ListPopup2`, `EditListPopup`, `EditableListPopup`, `SimpleEditPopup`, `FormPopup`, `FilePopup`, `YesNoPopup`, `CommanderPopup`, `DisksPopup`, `PopupClosingTranslator`, `StringAcceptance`, `FileAcceptance`, `Popups`
- `org.luwrain.i18n` — internationalization: `I18n`, `I18nImpl`, `I18nExtension`, `I18nExtensionBase`, `Lang`, `LangBase`, `LangStatic`, `PropertiesProxy`, `ResourceStringsObj`, `EmptyStringsObj`
- `org.luwrain.speech` — speech engine interfaces: `Engine`, `Channel`, `Voice`, `SpeechException`
- `org.luwrain.player` — media player interfaces: `Player`, `Factory`, `Playlist`, `FixedPlaylist`, `Listener`, `ProgressListener`, `VolumeListener`
- `org.luwrain.script` — scripting: `ScriptUtils`, `Hooks`, `HookException`, `Wizard`, `AsyncFunction`, `AsyncUtils`, and sub-packages `core`, `hooks`, `ml`, `app`, `controls`
- `org.luwrain.cpanel` — control panel: `ControlPanel`, `Factory`, `Section`, `Element`, `SimpleElement`, `SimpleSection`, `DefaultSection`, `DefaultElement`, `EmptySection`, `SectionArea`, `AdditionalSectionArea`, `StandardElements`
- `org.luwrain.shell` — shell/desktop: `MainMenu`, `ContextMenu`, `Config`, `Conversations`, `desktop/Desktop`, `desktop/DesktopArea`, `desktop/Appearance`, `desktop/Conversations`, `desktop/Strings`
- `org.luwrain.settings` — settings UI: `UserInterface`, `MainMenu`, `Version`, `DateTime`, `FileTypes`, `Braille`, `HotKeys`, `SoundsList`, `SoundSchemes`, `StandardFactory`, `PersonalInfo`, `HardwareCpuMem`, `Speech`
- `org.luwrain.util` — utilities: `FileUtils`, `TextUtils`, `TextAligning`, `TextFragmentUtils`, `UrlUtils`, `Urls`, `UrlUtils`, `Sha1`, `Connections`, `StreamUtils`, `ResourceUtils`, `RegistryUtils`, `PathUtils`, `ClassUtils`, `SoundUtils`, `MlTagStrip`, `WordIterator`, `LineIterator`, `LinesSaver`, `TempDir`, `RangeUtils`
- `org.luwrain.io` — I/O: `CommanderUtilsFile`, `EmptyFileFetching`, `download/DownloadManager`, `download/DownloadManagerFactory`, `download/LocalDownload`, `json/CommonSettings`, `json/DesktopItem`, `json/FileType`, `json/FileTypes`, `json/Braille`, `json/MainMenuItem`, `json/HotKey`, `json/HotKeys`, `json/PersonalInfo`, `json/Speech`, `websearch/Engine`, `websearch/Query`, `websearch/Entry`, `websearch/Response`
- `org.luwrain.registry` — registry: `Path`
- `org.luwrain.nlp` — NLP: `Word`, `POS`, `GrammaticalAttr`
- `org.luwrain.packs` — packs: `Packs`, `Pack`, `Version`
- `org.luwrain.interaction` — interaction: `KeyboardHandler`, `KeyboardLayout`, `layouts/RuDefault`
- `org.luwrain.linux` — Linux-specific: `MountParams`
- `org.luwrain.app.*` — built-in applications: `console`, `calendar`, `crash`, `base`, `cpanel`, `jobs`, `calc`

### Base Subproject (`base/`)

Contains base applications and the minimal launcher:

- `base/base` — minimal launcher (`luwrain-base.jar`): `Launcher`, `Init`, `NullCheck`, `StarterCategory`, `AnnotationProcessor`, `annotations/ResourceStrings`, `annotations/AppNoArgs`
- `base/javafx` — JavaFX interaction implementation (`luwrain-javafx.jar`): `JavaFxInteraction`, `App`, `ThreadControl`, `OnScreenLine`, `OnScreenLineTracker`, `ColorUtils`, `FxThread`, `ResizableCanvas`
- `base/player` — media player app (`luwrain-player.jar`)
- `base/app-notepad` — notepad app (`luwrain-app-notepad.jar`)
- `base/app-commander` — file commander app (`luwrain-app-commander.jar`)
- `base/app-viewer` — file viewer app (`luwrain-app-viewer.jar`)
- `base/app-video` — video player app (`luwrain-app-video.jar`)

### I/O Subproject (`io/`)

- `io/io` — I/O core (`luwrain-io.jar`): APIs for web search, AI, translation, file filters, NLP/spell checking, VFS, PDF, text document model, download management, various web APIs (OSM, Mastodon, GitHub, Yandex, Searx, DuckDuckGo, etc.)
- `io/app-telegram` — Telegram client
- `io/app-bsky` — Bluesky client
- `io/app-vk` — VK client
- `io/app-twitter` — Twitter client
- `io/app-mastodon` — Mastodon client
- `io/app-github` — GitHub client
- `io/app-matrix` — Matrix client
- `io/app-ai` — AI assistant
- `io/app-translate` — translation app
- `io/app-wiki` — wiki reader
- `io/app-osm` — OpenStreetMap viewer
- `io/app-opds` — OPDS catalog reader
- `io/app-weather` — weather app
- `io/app-openmeteo` — OpenMeteo weather
- `io/app-download` — download manager
- `io/app-alpha-tessera` — Alpha Tessera client

### PIM Subproject (`pim/`)

- `pim/pim` — PIM core (`luwrain-pim.jar`): mail, contacts, diary, news, fetching, binders, publishers
- `pim/app-mail` — mail app
- `pim/app-contacts` — contacts app
- `pim/app-diary` — diary app
- `pim/app-news` — news reader app

### Other Subprojects

- `browser/` — web browser (`luwrain-browser.jar`)
- `reader/` — book reader (`luwrain-reader.jar`)
- `studio/` — IDE/studio (`luwrain-studio.jar`)
- `bookdoc/` — document format library (`luwrain-bookdoc.jar`)
- `inlandes/` — grammar/scripting engine (`luwrain-grammar.jar`)
- `grammar/` — ANTLR grammars for Java, JavaScript, LilyPond, LaTeX
- `platform/` — platform-specific code:
  - `platform/linux` — Linux support
  - `platform/windows` — Windows support
  - `platform/app-linux-man` — man page viewer
  - `platform/app-linux-term` — terminal emulator
  - `platform/app-linux-rec` — audio recording
- `extensions/` — extensions:
  - Speech engines: RHVoice, VoiceMan, SpeechD, MSSAPI, CmdTTS, PicoTTS, BinTTS
  - Players: MP3, JavaFX, Ogg
  - Languages: Russian (i18n/ru), English (i18n/en), French (i18n/fr), Czech (lang/cz), Romanian (i18n/ro)
  - Other: Emacspeak

## Key Architectural Patterns

1. **Application Lifecycle**: Applications implement `Application` (or `MonoApp`). They receive a `Luwrain` instance via `onLaunchApp()`. The core manages app lifecycle through `AppManager`.

2. **Area Model**: All UI is built from `Area` objects. Areas produce visual lines, handle input events, and manage a hot point. Areas are arranged in layouts (`AreaLayout`).

3. **Extension System**: Extensions implement `Extension`, are loaded via `ServiceLoader`, and can provide commands, UniRef processors, control panel factories, i18n extensions, and extension objects.

4. **Event System**: Input events (`InputEvent`) and system events (`SystemEvent`) are dispatched to areas. Areas return `EventResponse` objects to control speech output.

5. **Speech**: Speech engines implement `org.luwrain.speech.Engine` and produce `Channel` objects. The `Speech` class manages the default channel.

6. **Interaction**: The `Interaction` interface abstracts screen rendering. Implementations exist for JavaFX (`base/javafx`).

7. **Configuration**: Configuration objects are POJOs saved/loaded via `Configs` using JSON serialization.

8. **Scripting**: Groovy/JavaScript scripting is supported via the `org.luwrain.script` package and GraalVM.

## Coding Conventions

- Opening curly braces on a new line
- Javadoc and all comments in English
- Use `NullCheck` methods for parameter validation
- Use `requireNonNull` from `java.util.Objects`
- Copyright header: `// SPDX-License-Identifier: BUSL-1.1` followed by `// Copyright 2012-2026 Michael Pozhidaev <msp@luwrain.org>`
- Package naming: `org.luwrain.<subproject>.<component>`
- Logging: Apache Log4j2 via `org.apache.logging.log4j.Logger`
- Use `static` imports for `NullCheck.*` and `java.util.Objects.*`

## Dependency Management

- Root `build.gradle` defines `ext.libraries` with dependency groups: `base`, `apacheBase`, `graalvm`, `antlr`, `antlrrt`, `h2`, `mcp`, `junit`, `autoService`
- Subprojects reference these via `libraries.<name>`
- Internal dependencies use `project(':luwrain-<name>')` notation
- Maven repositories: `https://download.luwrain.org/maven2/` and `https://mvn-mirror.gitverse.ru`