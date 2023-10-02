# Homework XX
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### MongoDB

**Цель:**<br>
* *В результате выполнения ДЗ вы научитесь разворачивать MongoDB, заполнять данными и делать запросы.*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

* Установить MongoDB одним из способов: ВМ, докер;
* Заполнить данными;
* Написать несколько запросов на выборку и обновление данных
  * Сдача ДЗ осуществляется в виде миниотчета.

Задача со _*_:
* Cоздать индексы и сравнить производительность.
  
***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены
* плюс 5 баллов за задание со звездочкой *

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. Попытка установить Mongo через Docker не удалась, т.к. нынче в Docker образы не входит CLI client:
   ```bash
   docker run --name my-mongo -d -p 27017:27017 mongo:latest
   ```
2. Поэтому я установил *mongo-tool-bin* в систему и подключился к контейнеру:
   ```bash
   mongosh --port 27017
   ```
3. Создадим коллекцию для выполнения домашнего задания:
   ```sql
   test> use otus;
   switched to db otus
   otus> db.createCollection("otusCollection");
   { ok: 1 }
   otus> 
   ```
4. Вставим данные:
   ```js
   db.mycollection.insertMany([
     { name: "Alice", age: 25, profession: "engineer" },
     { name: "Bob", age: 30, profession: "designer" },
     { name: "Charlie", age: 35, profession: "teacher" }
   ]);
   
   {
     acknowledged: true,
     insertedIds: {
       '0': ObjectId("651aa40ac71871aa9969b58a"),
       '1': ObjectId("651aa40ac71871aa9969b58b"),
       '2': ObjectId("651aa40ac71871aa9969b58c")
     }
   }
   ```
5. Запрос на выборку: 
   ```js
   db.otusCollection.find()
   [
     {
       _id: ObjectId("651aa3e4c71871aa9969b587"),
       name: 'Alice',
       age: 25,
       profession: 'engineer'
     },
     {
       _id: ObjectId("651aa3e4c71871aa9969b588"),
       name: 'Bob',
       age: 30,
       profession: 'designer'
     },
     {
       _id: ObjectId("651aa3e4c71871aa9969b589"),
       name: 'Charlie',
       age: 35,
       profession: 'teacher'
     }
   ]
   ```
* Выборка по критерию:
   ```js
   db.otusCollection.find({ age: { $gt: 28 } });
   [
     {
       _id: ObjectId("651aa3e4c71871aa9969b588"),
       name: 'Bob',
       age: 30,
       profession: 'designer'
     },
     {
       _id: ObjectId("651aa3e4c71871aa9969b589"),
       name: 'Charlie',
       age: 35,
       profession: 'teacher'
     }
   ]
   ```
* Обновление записей:
   ```js
   db.otusCollection.updateOne({ name: "Alice" }, { $set: { age: 26 } });
   {
     acknowledged: true,
     insertedId: null,
     matchedCount: 1,
     modifiedCount: 1,
     upsertedCount: 0
   }
   ```
6. Результат *explain* без индекса:
   ```js
   db.mycollection.find({ name: "Alice" }).explain("executionStats");
   {
     explainVersion: '2',
     queryPlanner: {
       namespace: 'otus.mycollection',
       indexFilterSet: false,
       parsedQuery: { name: { '$eq': 'Alice' } },
       queryHash: '1AD872C6',
       planCacheKey: 'A1119FAD',
       maxIndexedOrSolutionsReached: false,
       maxIndexedAndSolutionsReached: false,
       maxScansToExplodeReached: false,
       winningPlan: {
         queryPlan: {
           stage: 'COLLSCAN',
           planNodeId: 1,
           filter: { name: { '$eq': 'Alice' } },
           direction: 'forward'
         },
         slotBasedPlan: {
           slots: '$$RESULT=s5 env: { s1 = TimeZoneDatabase(Asia/Muscat...Atlantic/Canary) (timeZoneDB), s2 = Nothing (SEARCH_META), s3 = 1696245095930 (NOW), s7 = "Alice" }',
           stages: '[1] filter {traverseF(s4, lambda(l1.0) { ((l1.0 == s7) ?: false) }, false)} \n' +
             '[1] scan s5 s6 none none none none lowPriority [s4 = name] @"7e83adce-34b4-4fb8-aa1f-e7ccc795c1f3" true false '
         }
       },
       rejectedPlans: []
     },
     executionStats: {
       executionSuccess: true,
       nReturned: 2,
       executionTimeMillis: 0,
       totalKeysExamined: 0,
       totalDocsExamined: 6,
       executionStages: {
         stage: 'filter',
         planNodeId: 1,
         nReturned: 2,
         executionTimeMillisEstimate: 0,
         opens: 1,
         closes: 1,
         saveState: 0,
         restoreState: 0,
         isEOF: 1,
         numTested: 6,
         filter: 'traverseF(s4, lambda(l1.0) { ((l1.0 == s7) ?: false) }, false) ',
         inputStage: {
           stage: 'scan',
           planNodeId: 1,
           nReturned: 6,
           executionTimeMillisEstimate: 0,
           opens: 1,
           closes: 1,
           saveState: 0,
           restoreState: 0,
           isEOF: 1,
           numReads: 6,
           recordSlot: 5,
           recordIdSlot: 6,
           fields: [ 'name' ],
           outputSlots: [ Long("4") ]
         }
       }
     },
     command: { find: 'mycollection', filter: { name: 'Alice' }, '$db': 'otus' },
     serverInfo: {
       host: '3e53d1becaaf',
       port: 27017,
       version: '7.0.1',
       gitVersion: '425a0454d12f2664f9e31002bbe4a386a25345b5'
     },
     serverParameters: {
       internalQueryFacetBufferSizeBytes: 104857600,
       internalQueryFacetMaxOutputDocSizeBytes: 104857600,
       internalLookupStageIntermediateDocumentMaxSizeBytes: 104857600,
       internalDocumentSourceGroupMaxMemoryBytes: 104857600,
       internalQueryMaxBlockingSortMemoryUsageBytes: 104857600,
       internalQueryProhibitBlockingMergeOnMongoS: 0,
       internalQueryMaxAddToSetBytes: 104857600,
       internalDocumentSourceSetWindowFieldsMaxMemoryBytes: 104857600,
       internalQueryFrameworkControl: 'trySbeEngine'
     },
     ok: 1
   }
   ```
7. Создаем индекс
   ```js
   db.otusCollection.createIndex({ name: 1 });
   ```
8. Результат *exlain* с индексом:
   ```js
   db.otusCollection.find({ name: "Alice" }).explain("executionStats");
   {
     explainVersion: '2',
     queryPlanner: {
       namespace: 'otus.otusCollection',
       indexFilterSet: false,
       parsedQuery: { name: { '$eq': 'Alice' } },
       queryHash: '1AD872C6',
       planCacheKey: '5A087791',
       maxIndexedOrSolutionsReached: false,
       maxIndexedAndSolutionsReached: false,
       maxScansToExplodeReached: false,
       winningPlan: {
         queryPlan: {
           stage: 'FETCH',
           planNodeId: 2,
           inputStage: {
             stage: 'IXSCAN',
             planNodeId: 1,
             keyPattern: { name: 1 },
             indexName: 'name_1',
             isMultiKey: false,
             multiKeyPaths: { name: [] },
             isUnique: false,
             isSparse: false,
             isPartial: false,
             indexVersion: 2,
             direction: 'forward',
             indexBounds: { name: [ '["Alice", "Alice"]' ] }
           }
         },
         slotBasedPlan: {
           slots: '$$RESULT=s11 env: { s2 = Nothing (SEARCH_META), s1 = TimeZoneDatabase(Asia/Muscat...Atlantic/Canary) (timeZoneDB), s5 = KS(3C416C696365000104), s10 = {"name" : 1}, s3 = 1696245219323 (NOW), s6 = KS(3C416C69636500FE04) }',
           stages: '[2] nlj inner [] [s4, s7, s8, s9, s10] \n' +
             '    left \n' +
             '        [1] cfilter {(exists(s5) && exists(s6))} \n' +
             '        [1] ixseek s5 s6 s9 s4 s7 s8 [] @"d34caa63-2a93-419f-9f3b-9e90b613d606" @"name_1" true \n' +
             '    right \n' +
             '        [2] limit 1 \n' +
             '        [2] seek s4 s11 s12 s7 s8 s9 s10 [] @"d34caa63-2a93-419f-9f3b-9e90b613d606" true false \n'
         }
       },
       rejectedPlans: []
     },
     executionStats: {
       executionSuccess: true,
       nReturned: 1,
       executionTimeMillis: 1,
       totalKeysExamined: 1,
       totalDocsExamined: 1,
       executionStages: {
         stage: 'nlj',
         planNodeId: 2,
         nReturned: 1,
         executionTimeMillisEstimate: 0,
         opens: 1,
         closes: 1,
         saveState: 0,
         restoreState: 0,
         isEOF: 1,
         totalDocsExamined: 1,
         totalKeysExamined: 1,
         collectionScans: 0,
         collectionSeeks: 1,
         indexScans: 0,
         indexSeeks: 1,
         indexesUsed: [ 'name_1' ],
         innerOpens: 1,
         innerCloses: 1,
         outerProjects: [],
         outerCorrelated: [ Long("4"), Long("7"), Long("8"), Long("9"), Long("10") ],
         outerStage: {
           stage: 'cfilter',
           planNodeId: 1,
           nReturned: 1,
           executionTimeMillisEstimate: 0,
           opens: 1,
           closes: 1,
           saveState: 0,
           restoreState: 0,
           isEOF: 1,
           numTested: 1,
           filter: '(exists(s5) && exists(s6)) ',
           inputStage: {
             stage: 'ixseek',
             planNodeId: 1,
             nReturned: 1,
             executionTimeMillisEstimate: 0,
             opens: 1,
             closes: 1,
             saveState: 0,
             restoreState: 0,
             isEOF: 1,
             indexName: 'name_1',
             keysExamined: 1,
             seeks: 1,
             numReads: 2,
             indexKeySlot: 9,
             recordIdSlot: 4,
             snapshotIdSlot: 7,
             indexIdentSlot: 8,
             outputSlots: [],
             indexKeysToInclude: '00000000000000000000000000000000',
             seekKeyLow: 's5 ',
             seekKeyHigh: 's6 '
           }
         },
         innerStage: {
           stage: 'limit',
           planNodeId: 2,
           nReturned: 1,
           executionTimeMillisEstimate: 0,
           opens: 1,
           closes: 1,
           saveState: 0,
           restoreState: 0,
           isEOF: 1,
           limit: 1,
           inputStage: {
             stage: 'seek',
             planNodeId: 2,
             nReturned: 1,
             executionTimeMillisEstimate: 0,
             opens: 1,
             closes: 1,
             saveState: 0,
             restoreState: 0,
             isEOF: 0,
             numReads: 1,
             recordSlot: 11,
             recordIdSlot: 12,
             seekKeySlot: 4,
             snapshotIdSlot: 7,
             indexIdentSlot: 8,
             indexKeySlot: 9,
             indexKeyPatternSlot: 10,
             fields: [],
             outputSlots: []
           }
         }
       }
     },
     command: { find: 'otusCollection', filter: { name: 'Alice' }, '$db': 'otus' },
     serverInfo: {
       host: '3e53d1becaaf',
       port: 27017,
       version: '7.0.1',
       gitVersion: '425a0454d12f2664f9e31002bbe4a386a25345b5'
     },
     serverParameters: {
       internalQueryFacetBufferSizeBytes: 104857600,
       internalQueryFacetMaxOutputDocSizeBytes: 104857600,
       internalLookupStageIntermediateDocumentMaxSizeBytes: 104857600,
       internalDocumentSourceGroupMaxMemoryBytes: 104857600,
       internalQueryMaxBlockingSortMemoryUsageBytes: 104857600,
       internalQueryProhibitBlockingMergeOnMongoS: 0,
       internalQueryMaxAddToSetBytes: 104857600,
       internalDocumentSourceSetWindowFieldsMaxMemoryBytes: 104857600,
       internalQueryFrameworkControl: 'trySbeEngine'
     },
     ok: 1
   }
   ```