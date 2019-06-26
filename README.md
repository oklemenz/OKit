# OKit

> Easy to use application framework for Swift, to create apps based on models and storyboards with (almost) no code. 

**Core Features:**
- Models and Entities
- JSON storage (file, http)
- Partials (partitions)
- References
- Complex Bindings
- Invalidation
- Data and Images (incl. inline)
- Encryption
- Application Shell
- Slide-in menu
- Settings
- Face ID
- Protection + Timeout
- Theming (incl. dark theme)
- Backups (secured)
- Help Views
- Re-use cells
- Auto-key generation

**Core Technologies:**
- **Storyboard**: Application flow is designed with storyboards using model controllers and model controls
- **Model**: Models are named data object and inherit from `Model`
- **Model Entity**: Model entities are part of a model and inherit from `ModelEntity`
- **Codable**: Models and model entities are automatically (de)serialized using `Codable` protocol
- **Context**: Models and model entities can be used as context in model controllers and model controls
- **Binding**: Model controller and model control properties can be bound to model binding paths 
- **KVC**: Key value coding is used to update model objects using `@objc` annotation
- **Controller**: Model controllers are enabled for bindings and inherit from `ModelListTableController`,  `ModelDetailTableController` or subclasses
- **Control**: Model controls and model cells are enabled for bindings, where latter inherits from  `ModelTableCell` or subclasses
- **Inspectable**: Model controllers and model control are extended with `@IBInspectable` properties, maintainable in Interface Builder  

## Model

### Model Definition

The model definition is based on Swift classes, inheriting from  `Model`, possibly including nested entities inheriting from `ModelEntity`.
Model implicitly is also a (root) Model Entity and inherits all binding functionality.

**The following Model types exists:**
- `Model`: Model is read/stored as JSON to filesystem into `okit/data` folder of document directory using model name with `.json` extension 
- `ModelTransient`: Model is not read/stored (therefore handled transiently)
- `ModelEncrypted`: Model is read/stored as encrypted binary to filesystem into `okit/data` folder of document directory using model name with `.json` extension  
- `ModelHttp`: Model is read/stored as JSON via HTTP to configured endpoint (endpoint URL can be configured in `Info.plist` with key `OKitModelEndpointUrl`)
- `ModelEncryptedHttp`: Model is read/stored as encrypted binary via HTTP to configured endpoint (endpoint URL can be configured in `Info.plist` with key `OKitModelEndpointUrl`)

**Example:**

```swift
@objc(Shop)
class Shop: Model, Codable {
    var id: String!
    var books: [Book] = []
}

@objc(Book)
class Book: ModelEntity, Codable {
    var id: String!
    var name: String = ""
    var date: Date = Date()
    var marked: Bool = false
    var icon: ModelImage?
    var authors: [Author] = []
}

@objc(Author)
class Author: ModelEntity, Codable {
    var id: String!
    var name: String = "<New Author>"
}
```

**Explanations:**
- `@objc` keyword shall be used, in order to allow dynamic instantiation and key-value-observing (KVO) by model controllers in Swift to support binding.
- Models and model entities that shall be de(serialized) to JSON must conform to `Codable` protocol
- Automatic JSON de(serialization) with `Codable` protocol does not work for inherited properties and need to be handled manually using  `Encoder` and `Decoder`  protocols
- Property `var id: String!` is filled automatically with a UUID by framework, and is mandatory for supporting references to the model entities

### Model Registration

A model can be registered with the `Model` class and an optional name:
 
```swift
Model.initialize(window, secure: true) {
    self.shop = Model.register(Shop.self)
    self.catalog = Model.register(Catalog.self, "catalog")
}
```

If name is omitted, the model is registered as default model with the implicit name `default`.
The registration shall be done in  `application:didFinishLaunchingWithOptions` of `AppDelegate`.
Model instances can be stored in the application context  for later access.

### Store Model

A model can be stored calling `Model.store(...)` on the model instance:

```swift
Model.store(self.shop)
```

### Define Model State

In order to update all models together within a state, the following is registered:

```swift
Model.state() {
    Model.store(self.shop)
    Model.store(self.settings)
}
```

The state definition shall be done in  `application:didFinishLaunchingWithOptions` of `AppDelegate`.
This supports switching between encrypted/non-encrypted persistence and enables backup/import functionality.

### Store Model State

The models state can be stored with: 

```swift
Model.storeState()
```

Storing can be done e.g. in  `applicationDidEnterBackground` of `AppDelegate`.

### Restore Model State

The models state can be restored with: 

```swift
Model.restoreState()
```

Storing can be done e.g. in  `applicationWillEnterForeground` of `AppDelegate`.

## Model Entity

Model entities define the properties and corresponding types to be stored. Model entities conformable to `Codable` are serialized to and deserialized from JSON.  
Model entities can again recursively contain array, map, set or single references of model entities again. Binding is supported for model entities to controllers and controls.  

### Model Binding

UI controllers and UI controls can be bound to model entities (context) using the following binding definitions:

**Type** | **Syntax** | **Example** | **Description**
--- | --- | --- | --- |
Constant | # |  `#true` | Constants of type String, Bool, Int, Float, Double (cannot be combined with other types)
Localized Constant | % |  `%xyz` | Constants of type String interpreted as localized string key
Model | > |  `xyz>` | Identifies model name, if omitted `default` model is used
Path | / | `x/y` | Separates path segments
Absolute | / | `/x/y/z` | Processing starts from model root (ignoring current context)
Relative | / | `x/y/z` | Processed relatively to the current context
Self | . | `/./` | Stays on current context
Parent | .. |  `/../` | Traverses parent relation relatively to current context
Root | \< or ~ |  `/~/` | Traverses to root relation (model) from current context
Bool Negation | ! |  `!/xy` | Negates value of binding in context of Boolean retrieval (only at front of binding allowed)
Reference | $ | `$xyz`| Identifies a reference context, i.e. the string value behind, is used to look up target context (model entity) using `ref()` function
Function | fn() | `xyz()`| Execute function on current context
Function with Parameter | fn(...) | `xyz(/a/b)` | Executes function on current context with parameter binding
Index | [] | `xy[0]/z`| Access current array context by index
KeyPath | .@ | `a.b.c@avg.d` | Executes `KeyPath` expression on current context according to Swift language
Multiple | , | `x/y,/a/b` | Executes multiple bindings separated by comma ','. Use  `getAll()` in code to fetch array of binding results

A complex binding example looks as follows:

`m1>/a/$b/../c()/d[1]/e(/a)/f.g.@avg.h`

To use special binding characters in a text string, those characters could be escaped by using the unicode representation. 
E.g. a comma is represented by **\u{002c}**.

### Extension Function Binding 

Functions and properties of core data types (e.g. Number, String, Date...) can be accessed within a binding:

Examples:

- `authors.@count/suffixPlural(#entry)`: The number returned by `@count` is suffixed by a translatable and pluralized string. 
- `%Price: ,price/round2, %EUR`: Multiple part binding adding the currency to the price value
- `name/initial`: String extension to return the first character of name
- `date/formatRelativeDate`: Date extension to format the date as relative date

Any Swift/Obj-C type can be extended with additional function and properties, and be used in binding expressions.

### Model Entity Invalidation

Updating a model entity by binding or respective `get`, `set`, `call` functions programatically, triggers an invalidation mechanism (unless `suppressInvalidate` is specified).
The invalidation notifies all bound controllers and controls for updating their content. 

### Model Entity Reuse 

- `ModelRef`: Reuse model entity for storing entity references
- `ModelData`: Reuse model entity for storing arbitrary binary data. Data is stored separately according to model type (file, http, encrypted, transient) and read lazily
- `ModelImage`: Reuse model entity for storing model images. Image data is stored separately according to model type (file, http, encrypted, transient) and read lazily
- `ModelInlineData`: Reuse model entity for storing abitrary data. Data is stored inline into model entity JSON data
- `ModelInlineImage`: Reuse model entity for storing model images. Image data is stored inline into model entity JSON data
- `ModelSettings`: Reuse model entity for storing application model settings (e.g. theme, encryption, protection, ...)

### Model Entity References

A model entity can be referenced, by using model entity library `ModelRef`. 

**Example:**

```swift
@objc(Book)
class Book: ModelEntity, Codable {

    var id: String!
    var name: String = ""
    var author: ModelRef = ModelRef()
    
}
```

Model entity `Book` references the model entity `Author` by its key (`ID`). Author is therefore not stored as composition, but only the 
reference key is stored as foreign key in Book. Both entities must be in the same model entity partial (see next section) 
in order be able to resolve the reference lazily via property `book.author.ref`.

### Model Entity Partials

A model partitioning (partials) can be established by inheriting from `ModelPartial` and by implementing the `sync` and `store` functions.  

**Example:**

```swift
@objc(GroupDefer)
class GroupDefer: ModelPartial, Codable {
    var id: String!
    var name: String = "" {
        didSet {
            group?.name = name
        }
    }
    var group: Group? {
        get {
            return try? retrieve(Group.self)
        }
        set {
            assign(newValue)
        }
    }

    override func sync(entity: ModelEntity) {
        name = (entity as! Group).name
    }

    override func store() {
        try? store(group)
    }
}

@objc(Group)
class Group: ModelEntity, Codable {
    var id: String!
    var name: String = ""
}
```

Entity `Group` is resolved lazily within partial `GroupDefer` by reading/storing from a different URL. 
Function `sync` and `didSet` can be used to two-way sync properties available in both entities (e.g. `name`).
Function  `store` is called to store the partition data.

### Model Entity Lifecycle Hooks

#### Managed Hook

Callback function `managed` can be overridden to implement lifecycle hook, when model entity is part of a context, 
i.e. parent entity or collection property of parent entity. 

```swift
open dynamic func managed(_ context: Any? = nil) {
    // ...
}
```

Context can be the parent entity or a collection of the parent entity.

#### Unmanaged Hook

Callback function `unmanaged` can be overridden to implement lifecycle hook, when model entity is removed from a context.

```swift
open dynamic func unmanaged(_ context: Any? = nil) {
    // ...
}
```

Context can be the parent entity or a collection of the parent entity.

## Storyboards/Controllers

User-Interfaces are built with storyboards, using standard `View Controllers` and `Table View Controller` by setting the following model classes as custom class:

- `ModelListTableController`: Represents a list controller of model entities
- `ModelDetailTableController`: Represents the details controller of a model entity
- `ModelSelectionTableController`: Displays a selection list controller for selecting single or multiple model entities
- `ModelApplicationController`: Represents the application environment for slide-in menu and protection support
- `ModelMenuTableController`: Represents the menu controller visible in the slide-in menu container
- `ModelSettingsTableController`: Represents the settings controller, to show model settings
- `ModelBackupTableController`: Represents the backup controller, to create and import backups
- `ModelSecureBackupTableController`: Represents the secure backup controller, to create and import secure backups

Model controllers have `@IBInspectable` properties defined, that are interpreted by Interface Builder to enhance the Attributes Inspector side pane.

Model controllers can inherit from `ModelBaseTableController` to get common binding functionality. 
Of course, each model controller can be further sub-classed for more use-case specific functionality.

Even usage of storyboards are recommended, UIs can also be built programmatically using the model controllers directly in code.

### Storyboard Identifiers 

#### Model Cell

Always use cell identifier `model` for dynamic prototype cells using model classes in storyboard. 

#### Model Segue

Always use segue identifier `model` for segue between model table and model detail table in storyboard.

## \<abstract\> Model Base Table

The model base table controller contains binding logic, etc., common to all model controllers.

The following `@IBInspectable` properties exist on the model table `ModelBaseTableController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Controller | ModelEntity |
promptPath | Binding path to navigation prompt | Yes | Navigation Item | String |
titlePath | Binding path to navigation title | Yes | Navigation Item | (Attributed)String |
titleTap | Binding path to navigation title tap | Yes | Navigation Item | Function |
titleCount | Binding path to navigation title count number | Yes | Navigation Item | Int |
subTitlePath | Binding path to navigation sub-title | Yes | Navigation Item | (Attributed)String |
subTitleObject | Binding path to navigation sub-title object name | Yes | Navigation Item | String |
subTitleObjectPlural | Binding path to navigation sub-title object plural name | Yes | Navigation Item | String |
subTitleSwap | Binding path to flag, specifying if title and sub-title are swapped | Yes | Navigation Item | Bool | #false
edit | Binding path to flag, controlling edit button visibility | Yes | Navigation Bar | Bool | #true
editEnabled | Binding path to flag, controlling table row editing support | Yes | Table Row | Bool | #true
editInherit | Binding path to flag, specifying if editing state is inherited from preceding controller | Yes | Controller | Bool | #false
editAlways | Binding path to flag, specifying if editing state is always enabled | Yes | Controller | Bool | #false
help | Binding path to flag, controlling the help button visibility | Yes | Navigation Bar | Bool | #true
forceUpdate | Binding path to flag, specifying if table is updated on invalidation, although modification was triggered from this controller | Yes | Controller | Bool | #true

## Model List Table

The model list table controller  `ModelListTableController` displays a list of model entities in a table view controller.

The following `@IBInspectable` properties exist on the model table `ModelListTableController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
type | Binding path to list type | No | Controller | String |
typeName | Binding path to list type name | No | Controller | String |
dataPath | Binding path to table data | Yes | Table | Array\<ModelEntity\>, Set\<ModelEntity\>  |
rowSort | Binding path to property, table data is sorted by | Yes | Table | String | 
rowSortAsc | Binding path to flag, specifying if data is sorted ascending | Yes | Table | Bool | #true
group | Binding path to property, table data is grouped by | Yes | Table | String |
groupName | Binding path to a property representing a readable name for the group property | Yes | Table | String |
groupSort | Binding path to a flag, specifying if the groups are sorted | Yes | Table | Bool | #true
groupSortAsc | Binding path to a flag, specifying if the groups are sorted ascending | Yes | Table | Bool | #true
reorder | Binding path to a flag, specifying if reordering is allowed for table | Yes | Table | String | #false
reorderEnabled | Binding path to a flag, specifying if reordering is allowed for a table row | Yes | Table Row | String | #true
tap | Binding path to row tap | Yes | Table Row | Function |
tapEdit | Binding path to row tap in edit mode | Yes | Table Row | Function |
selectPath  | Binding path to multiple selection event during editing | Yes | Table Row | Function |
refresh | Binding path to flag, controlling visibility of refresh control | Yes | Table | Bool | #true
search | Binding path to flag, controlling visibility of search bar | Yes | Search Bar | Bool | #true
searchPath | Binding path to property used for searching in entity | Yes | Search Bar | String | description
searchFilterPath | Binding path to property used for filtering in entity | Yes | Search Bar | String | 
searchFilters | Multipart binding path to search bar scope buttons | Yes | Search Bar | String |
index | Binding path to flag, controlling visibility of A-Z index | Yes | Table | Bool | #false
add | Binding path to flag, controlling visibility of add button | Yes | Navigation Bar | Bool | #true
addAppend | Binding path to flag, specifying if new entries are appended or inserted at top | Yes | Navigation Bar | Bool | #false
addName | If non-empty, it enables a "new entry" dialog, where the property specifies the text field label | No | Controller | String |
addNav | Binding path to flag, specifying if detail navigation to newly created entity is triggered | Yes | Controller | Bool | #false
navEnabled | Binding path to flag, specifying if navigation is allowed for table row | Yes | Table Row | Bool | #true
delete | Binding path to flag, specifying if row deletion is allowed for table | Yes | Table | Bool | #true
deleteEnabled | Binding path to flag, specifying if row deletion is allowed for table row | Yes | Table Row | Bool | #true 
deletePrompt | Binding path to flag, controlling visibility of a delete prompt dialog | Yes | Controller | Bool | #true
more | Binding path to flag, specifying if more button in row is available for table | Yes | Table | Bool | #false
moreEnabled | Binding path to flag, specifying if more button in row is available for table row | Yes | Table Row | Bool | #true
moreTap | Binding path to more button tap | Yes | Table Row | Function |
moreActions | Multipart binding path to more action-sheet action names | Yes | Action Sheet | String |
moreActionsEnabled | Multipart binding path to more action-sheet actions enablement | Yes | Action Sheet | Bool |
moreActionsTap | Multipart binding path to more action sheet actions tap | Yes | Action Sheet | Function |
quickName | Binding path to quick action name | Yes | Table | String |
quickImage | Binding path to quick action image | Yes | Table | UIImage |
quickEnabled | Binding path to flag, specifying if quick action is enabled for table row | Yes | Table Row | Bool | #true
quickTap | Binding path to quick button tap | Yes | Table Row | Function |
autoDeselect | Binding path to flag, specifying if row is auto deselected after tap | Yes | Table Row | Bool | #true
forceListUpdate | Binding path to flag, specifying if list table is updated on invalidation, although modification was triggered from this controller | Yes | Controller | Bool | #false
activityTop | Binding path to activity indicator top margin value | Yes | Table | Float | #20.0
activity | Binding path to activity indicator visibility | Yes | Table | Bool | #false

## Model Detail Table

The model detail table controller `ModelDetailTableController` displays details of one model entity in a table view controller.

The following `@IBInspectable` properties exist on the model table `ModelDetailTableController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
sectionHeaders | Multipart binding path to section headers | Yes | Table | String | 
sectionFooters | Multipart binding path to section footers | Yes | Table | String |
tap | Binding path to row tap | Yes | Table Row | Function |
tapEdit | Binding path to row tap in edit mode | Yes | Table Row | Function |
accyTap | Binding path to accessory tap | Yes | Table Row | Function |
accyEditTap | Binding path to accessory tap in edit mode | Yes | Table Row | Function |
autoDeselect | Binding path to flag, specifying if row is auto deselected after tap | Yes | Table Row | Bool | #true
sectionsShowDisplay | Multipart binding path to flags, controlling section visibility | Yes | Table | Bool | 
sectionsShowEdit | Multipart binding path to flags, controlling section visibility in edit mode | Yes | Table | Bool |

## Model Selection Table (Model List Table)

The model selection table controller  `ModelSelectionTableController` displays a list of model entities for selecting a single or multiple model entities in a table view controller.

The following `@IBInspectable` properties exist on the model table `ModelSelectionTableController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
refType | Binding path to selection reference type | No | Controller | String |
refTypeName | Binding path to selection reference type name | No | Controller | String |
selectionContextPath | Binding path to selection context | Yes | Controller | ModelEntity |  
selectionPath | Binding path to selection references in selection context | Yes | Controller | ModelRef, Array\<ModelRef\>, Set\<ModelRef\> |
selectAppend | Binding path to flag, specifying if selection references are appended or inserted at top | Yes | Controller | Bool | #false
unique | Binding path to flag, specifying if same entity can be selected multiple times | Yes | Controller | Bool | #true
unselect | Binding path to flag, specifying if selecting an already selected entity does unselect it | Yes | Controller | Bool | #true
clear | Binding path to flag, specifying if clear button is available | Yes | Navigation Bar | Bool | #true
close | Binding path to flag, specifying if close button is available | Yes | Navigation Bar | Bool | #true
autoClose | Binding path to flag, specifying if selection does auto-close selection table | Yes | Controller | Bool | #false

## Model Application 

The model application controller `ModelApplicationController` displays the application environment including content and slide-in menu area.
It shows the model menu table and controls content display based on storyboard identifier.  

The following `@IBInspectable` properties exist on the model table `ModelApplicationController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
storyboardName | Default storyboard name | No | Controller | String | Main
menuIdentifier | Storyboard controller identifier for menu | No | Controller | String | menu
homeIdentifier | Storyboard controller identifier for home/default content | No | Controller | String | home
popGesture | Flag to specify if interactive pop gesture is allowed on content controller  | No | Controller | Bool | false  
contextPath | Context path for bindings | Yes | Controller | ModelEntity |
themeName | Binding path to theme name | Yes | Controller | String | 
encryption | Binding path to encryption flag | Yes | Controller | Bool | #true
protection | Binding path to protection flag | Yes | Controller | Bool | #true
protectionTimeout | Binding path to  protection timeout (in minutes) | Yes | Controller | Int | #5
protectionCover | Binding path to protection cover visibility flag | Yes | Controller | Bool | #true
protectionImage | Binding path to protection cover image | Yes | Controller | UIImage |
protectionText | Binding path to protection cover text | Yes | Controller | String |

### Protection

Application can be protected by Face ID, if activated in the model settings. When protection is active a protection cover is shown, to hide sensitive application data below, when leaving the application. The protection timeout specified in minutes, if a re-authentication with Face ID is needed to suspend protection cover.

## Model Menu Table (Model List Table)

The model menu table controller `ModelMenuTableController` displays the menu in the model application controller. 
It is used to show content via storyboard identifier, depending on the menu selection.

The following `@IBInspectable` properties exist on the model table `ModelMenuTableController`:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
storyboardName | Default storyboard name | No | Controller | String | Main
identifier | Storyboard controller identifier for default target navigation  | No | Controller | String |
rowIdentifier | Storyboard controller identifier for row accessory tap | No | Cell | String |
hideMenu | Flag to specify, if menu is closed after navigation | No | Cell | Bool | true

### Model Menu Bar Button Item

A `UIBarButtonItem` representing a menu button (incl. burger icon), that can be used out-of-the box.

## Menu Settings Table (Model Detail Table)

The model settings table controller `ModelSettingsTableController` displays the model settings in the model application controller.
Model detail table controller bindings against the  `ModelSettings` entity shall use `ModelSettingsTableController` base class, 
as settings invalidation for theme, encryption, protection, etc. is then handled automatically. 

## Model Backup Table

The model backup table  `ModelBackupTableController` displays a list of model backups. Furthermore, new backups can be created, or existing backups can be deleted. During backup all models are exported. Selecting a backup triggers the import of an existing backup, which overrides the current models after showing a confirmation popup.

Backups are stored in `okit/backup` folder of document directory. 

### Model Secure Backup Table

The model secure backup table  `ModelSecureBackupTableController`  enables a security popup, for entering the passcode for backup creation and backup import:  

```swift
open func dataToBackup(sourceURL: URL, targetURL: URL, name: String, password: String) throws -> Bool
```
Function `dataToBackup` e.g. can be overridden in sub-class to create and copy a password-protected zip file.

```swift
open func backupToData(sourceURL: URL, targetURL: URL, name: String, password: String) throws -> Bool
```

Exports are temporarily stored in `okit/export` folder of document directory, to be further processed by backup logic.
Function `backupToData` e.g. can be overridden in sub-class to extract password-protected zip file and copy to target.

## Model Theming

A built-in theming concept is available. Central class is `ModelTheme`. There are two out-of-the box themes:

- `ModelTheme.defaultTheme`: iOS default theme
- `ModelTheme.darkTheme`: A default dark theme provided by framework

### Custom Theme

Own custom themes can be created and registered in the `ModelTheme` class with function:

```swift
public static func register(theme: ModelTheme, name: String)
```

Themes can be set at the model application using model binding or by explicitly using `func applyTheme(_ theme: ModelTheme?)`. 

## Model Controls

### \<abstract\> Model View

Abstract base class for view-based controls, supporting model binding.

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Control | ModelEntity |

### Model Help View

A help view can be connected to `IBOutlet helpView` for list and detail model controller. It handles displaying of modal help view and discarding. 
Help view content can be statically modeled in storyboard or dynamically by sub-classing model help view.

### Model Label

Bindable representation of an `UILabel`
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Label | ModelEntity |
textPath | Binding path to label text | Yes | Label | (Attributed)String |
showPath | Binding path to label visibility | Yes | Label | Bool |

### Model Button

Bindable representation of an `UIButton`
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Button | ModelEntity |
iconPath | Binding path to button icon | Yes | Button | UIImage |
titlePath | Binding path to button title | Yes | Button | String |
tapPath | Binding path to button tap | Yes | Button | Function |
showPath | Binding path to button visibility | Yes | Button | Bool |
enabledPath | Binding path to label enabled state | Yes | Button | Bool |

### Model Bar Button Item

Bindable representation of an `UIBarButtonItem`. 
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Bar Button Item | ModelEntity |
tapPath | Binding path to tap | Yes | Bar Button Item | Function |
enabledPath | Binding path to enabled state | Yes | Bar Button Item | Bool | 

### Model Menu Bar Button Item

A `UIBarButtonItem` representing a menu button (inc. burger icon), that can be used out-of-the box.

## Model Cells

### Table Cell

Bindable representation of an `UITableViewCell`.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
contextPath | Context path for bindings | Yes | Cell | ModelEntity |
path | Binding path to text label text | Yes | Text Label | (Attributed)String |
detailPath | Binding path to detail text label text | Yes | Detail Text Label | (Attributed)String |
imagePath | Binding path to image view image | Yes | Image View | UIImage |
ribbonColor | Context path for cell ribbon color | Yes | Cell | Color |
editPath | Binding path to text label text in edit mode | Yes | Text Label | (Attributed)String |
editDetailPath | Binding path to detail text label text in edit mode | Yes | Detail Text Label | (Attributed)String |
editImagePath | Binding path to image view image in edit mode | Yes | Image View | UIImage |
editRibbonColor | Context path for cell ribbon color in edit mode| Yes | Cell | UIColor | 
accyPath | Binding path to accessory type | Yes | Cell Accessory Type | AccessoryType, Int |
accyIcon | Binding path to accessory view button icon | Yes | Cell Accessory View Button | UIImage |
accyText | Binding path to accessory view button text | Yes | Cell Accessory View Button | String |
accyTap | Binding path to accessory view tap | Yes | Cell Accessory View  | Function |
accyShow | Binding path to accessory view visibility | Yes | Cell Accessory View | Bool | #true
accyEnabled | Binding path to accessory view button enablement | Yes | Cell Accessory View Button | Bool | #true
accyEditPath | Binding path to accessory type in edit mode | Yes | Cell Accessory Type | AccessoryType, Int |
accyEditIcon | Binding path to accessory view button icon in edit mode | Yes | Cell Accessory View Button | UIImage |
accyEditText | Binding path to accessory view button text in edit mode | Yes | Cell Accessory View Button | String |
accyEditTap | Binding path to accessory view tap in edit mode | Yes | Cell Accessory View  | Function |
accyEditShow | Binding path to accessory view visibility in edit mode | Yes | Cell Accessory View | Bool | #true
accyEditEnabled | Binding path to accessory view button enablement in edit mode | Yes | Cell Accessory View Button | Bool | #true
heightDisplay | Binding path to cell height | Yes | Cell | Float |
heightEdit | Binding path to cell height in edit mode | Yes | Cell | Float |
heightSelect | Binding path to cell height in select mode | Yes | Cell | Float | 
showDisplay | Binding path to cell visibility | Yes | Cell | Bool | #true
showEdit | Binding path to cell visibility in edit mode | Yes | Cell | Bool | #true
selectNextRow | Binding path to next (positive) / previous (negative) cell index to delegate selection | Yes | Cell | Int | 
selectNextAccent | Binding path to accent coloring during next row selection | Yes | Cell | Bool | #true

### \<abstract\> Edit Cell (Table Cell)

Bindable representation of an editable  `UITableViewCell`.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
readOnly | Binding to control read-only state | Yes | Control | Bool | #false
controlInDisplay | Binding to show/hide control in display mode  | Yes | Control | Bool | #true

### Switch Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UISwitch` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
onPath | Binding path to switch isOn property | Yes | Switch | Bool |

### Text Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UITextField` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
textPath | Binding path to text field text | Yes | Text Field | String |
placeholder | Binding path to text field placeholder | Yes | Text Field | String | 
secure | Binding path to text field secure text entry | Yes | Text Field | Bool | #false

### Date Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UIDatePicker` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
datePath | Binding path to date control date | Yes | Date Picker | Date |
minDatePath | Binding path to date control minimum date | Yes | Date Picker | Date |
maxDatePath | Binding path to date control maximum date | Yes | Date Picker | Date |
modePath | Binding path to date control mode | Yes | Date Picker | UIDatePicker.Mode, Int | #2

### Multiline Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UITextView` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
textPath | Binding path to text view text | Yes | Text View | String |
placeholder | Binding path to text view placeholder  | Yes | Text View | String |

### Segment Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UISegmentedControl` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
segmentsPath | Multipart binding path to segments | Yes | Segmented Control | String |
selectIndexPath | Binding path to segment selection index | Yes | Segmented Control | Int |
width | Binding path to control width | Yes | Segmented Control | Float | #200

### Picker Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UIPickerView` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
dataPath | Binding path to picker data | Yes | Picker View | Array\<ModelEntity\>, Set\<ModelEntity\> | 
namePath | Binding path to picker data row name property | Yes | Picker View Row | String | 
selectionPath | Binding path to picker selection | Yes | Picker View | Int |

### Slider Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UISlider` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
valuePath | Binding path to value | Yes | Slider | Float |
minValuePath | Binding path to minimum value | Yes | Slider | Float | #0
maxValuePath | Binding path to maximum value | Yes | Slider | Float | #1
minImagePath | Binding path to minimum value image | Yes | Slider | UIImage |  
maxImagePath | Binding path to maximum value image | Yes | Slider | UIImage |
width | Binding path to control width | Yes | Slider | Float | #150

### Stepper Cell (Edit Cell)

Bindable representation of an  `UITableViewCell` containing an `UIStepper` control.
The following `@IBInspectable` properties exist:

**Name** | **Description** | **Bindable** | **Context** | **Type** | **Default**
--- | --- | --- | --- | --- | --- |
valuePath | Binding path to value | Yes | Stepper | Double |
minValuePath | Binding path to minimum value | Yes | Stepper | Double | #0
maxValuePath | Binding path to maximum value | Yes | Stepper | Double | #100
stepValuePath | Binding path to step value | Yes | Stepper | Double |  #1

## Model Help View

A help view can be connected to `IBOutlet helpView`.

## Model Inheritance

Any model entities, controllers and controller can be inherited and functions overridden to change default behavior, as most definitions are marked as `open` and `public`. 

# OKit Demo: Bookshop

A full-fledged example project is available, showcasing every feature of the `OKit` framework. 
It can be found in folder `/Examples/Bookshop`.
