# Notes

## Base classes:

 - `com.biqasoft.fiffs.system.BaseClass` base value object for all entities stored in database
 - `com.biqasoft.fiffs.filters.BiqaClassFilterAbstract` base value class for filters for BaseClass objects
 - `com.biqasoft.common.system.BuilderServicePrimary` create DB requests, based on value object BiqaClassFilterAbstract

### Gateway

 - `com.biqasoft.entity.core.CurrentUser` interface for current HTTP bounded request. `CurrentUserImpl` is impl for REST api
 - `com.biqasoft.gateway.configs.MongoTenantConfiguration` multitenancy

## Date & Time
 - All dates in database stores in UTC-0.
 - And response in API with timezone offset 0 too. API Client should care about local timezone offset

## Aspects

#### Update user documents
При создании объекта создаётся `createdInfo`. Для того, чтобы его нельзя было перезаписать,
пользовательские изменения уже существующего объекта необходимо делать через функцию

```java
builderService.updateToDBDefaultBiqa(company);
```

Это функция:
 - НЕ обновляет поля с новым (запрошенным) значением `null`
 - НЕ обновляет поля в корне объекта с аннотацией `@BiqaDontOverrideField`
 - Работает только для полей в корне объекта, включая унаследованные, но не обновляет вложенные

#####  @BiqaAddObject
Аннотация вещающая на функции, в результате - вызывается функция (аспект - com.biqasoft.gateway.system.BeforeObjectAdd),
добавляющая createdInfo и domain к входным аргументам biqaAbstract.
Используется в репозиториях перед добавлением в БД данных в первый раз

```java
@BiqaAddObject
public Customer addCustomer(Customer customer) {...}
```

Вызывает функцию  `lead =  builderService.checkAndSetDefaultBiqa(lead); `

##### Дата создания и кто создал
`CreatedInfo createdInfo = new CreatedInfo( new Date() , currentUser.getCurrentUser().getId()  );`

#### Get current user domain

```java
@Autowired
private CurrentUser currentUser;
...
currentUser.getDomainInCRM().getDomain(); // "9ujscvbfbv"
```

### Notes
 - If you want to use proxy for JVM for all request/response - note, that standard `dropbox SDK` will refuse your self-signed CA cert

### External libs
To support WebDav for files used `https://github.com/lookfirst/sardine/wiki/UsageGuide`

## Aspects

### `@BiqaAuditObject`

 - get all arguments to function
 - get mongodb collection name from java classname
 - if this class extends BaseClass - get if of this class
 - after execution this function - get object from database with this id
 - Javers: compare this object with old object
 - Javers: write history

So, it it absolutely safe to pass to function only class with id and do some logic that modify class in database 

For example, we have class id, and this is Customer class. We can

```java
Customer customer = new Customer();
customer.setId(ourId)

@BiqaAuditObject
public Customer modifyCustomer(Customer customer){
    
    Query query = new Query(Criteria.where("id").is(customer.getId()));
    Update update = new Update().set("name", "Mark");
    
    customer.setName("Mark");
    mongoTemplate.findAndModify(query, update, Customer.class);
}
```

### Send invalid request to user
You can throw exception in code if user request has wrong data

ThrowExceptionHelper in server:
 - `throwExceptionInvalidRequest(String message)` example `ThrowExceptionHelper.throwExceptionInvalidRequest("No customer with such id");`
 - `throwExceptionInvalidRequestLocalized(String message)` example `ThrowExceptionHelper.throwExceptionInvalidRequestLocalized("invalid.request.no_customer");`

Response exception to client handled by `com.biqasoft.gateway.configs.exceptionhandler.MyExceptionHandler`
```json
{
	"code": "InvalidRequest",
	"message": "Нет такого клиента",
	"fieldErrors": null,
	"englishErrorMessage": "No customer with such id",
	"idErrorMessage": "invalid.request.no_customer"
}
```

Message field depend on user account language (`CurrentUser.getLanguage()`)

After executing this method we will update only name of our customer, which define in function.

##
To check that user have some permission you should use something like this(because auth microservice can grant some permission depending on the membership in groups, etc.):
`if (!SecurityContextHolder.getContext().getAuthentication().getAuthorities().contains(new SimpleGrantedAuthority(SYSTEM_ROLES.ROLE_ADMIN)))` or `currentUser.haveRole(SYSTEM_ROLES.ROLE_ADMIN)`


## Style guide

 - project prefix is biqa (`BiqaAddObject`, `BiqaAuditObject`, `BaseClass` ).
 - property name example start with prefix too `biqa.internal.exception.strategy`

### API

Use `_` as separator
`indicators/filter/lead_gen_method` / `myaccount/set_online`

### Template system (handlebars)

```html
{{#ifCond type '==' 'USER_ACCOUNTS'}}
   <br>
   <span>
       {{#each value.stringList}}
           <a href="/userAccount/details/{{this}}"></a>
       {{/each}}
   </span>
{{/ifCond }}
```

### Be careful when edited models in db / API transfer
Avoid some fields to be included in response (such as password, secret keys, token)

 - `@JsonIgnore` - Jackson
 - `@DiffIgnore` - Javers
