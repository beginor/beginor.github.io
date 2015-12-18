---
layout: zzm
title: Zhimin Zhang's Resume
show_in_sitemap: false
---

### Basic Info

Zhimin Zhang | Male | 10 Years of Exp | 134-1805-6213 | beginor@qq.com | http://beginor.github.io

### Desired Position

Guangzhou, Fulltime, 20-25K/M, Architector > Technical Manager > Senior Developer

### Self Assessment

- 10 years experience playing with microsoft .Net framework, and Five years of dev team management; 
- Excellent director in the dev team; 
- Familiar with Design Patterns, aware of popular open source framework， have self opinion of the common internet production; 
- Familiar with C#, .Net BCL and SQL Server;
- Familiar with HTML5/CSS3/Javascript, and AngularJS, Bootstrap and Compass;
- Familiar with data structor and algorithms;

### Skill List

I am familiar with those skills:

- Languages: C#, Javascript, C/C++
- Web Dev: ASP.NET, MVC, WebApi
- Back-End: NHibernate, MyBatis.NET(iBatis.NET), EntityFramework, Unity
- Front-End: AngularJS, Bootstrap, ExtJS, HTML5, jQuery, SCSS
- Database: SQL Server, MySQL, SQLite
- Version Control: Git, Svn, TFS

### Work Experience

- Technical Leader of 2020 Technologies Inc. (2015-05 ~ 2015-11)

  1. Construction of Dev team, specification of documention, improve company's documenting;
  2. Prototype of product foundation;
  3. Training of Dev and deploy stuff; 
  4. Participate in making workflow standards of Dev and deploy stuff;
  5. Participate in product planing and project soluation;
  
- Team Leader of GDEIC (2005-03 ~ 2015-04)

  Responsible for software architech design and implementation， go through Browser/Server, Silverlight RIA and Mobile + REST Service periods:

  1. In Browser/Server period, combine of ExtJS for the browser side, AjaxHandler (independent develop) for the server side, iBATIS.NET for data access and custom code gernation template, build a complete rapid development framework, and apply it to the develop team. The most successful project is Online Monitoring System of GDEP, which had been deployed to more then ten cities/regions.
  2. In the Silverlight RIA period, the most important requirement is rendering and showing the data from Online Monitoring System. Because of the poor performance of Browser, We switch to use Silverlight for the browser side, and  ASP.NET MVC for the serverside, NHibernate for data access. The both side is using C# code, We use dynamic analysis of lambda expression for the communication between the server and client, reduce hard code and increase the effciency of develop team. We also use Microsoft Unity as Ioc Container decouple the combination of modules. The most successful project is SilverGIS. 
  3. In the Mobile + Service period, with the requirment of mobile develop, considering the experience of .NET, we use Xamarin/Mono as our mobile development soluation; on the server side, we also start to use ASP.NET WebApi to provide RESTful service, and also start to try runing ASP.NET WebAPI on Linux + Mono environment through OWIN. At browser side, we also start to use AngularJS and Bootstrap to build single page application (SPA), with asynchronous module definition of Require.JS, we atchieve loading on demand of AngularJS module/controller.

### Project Experience

- Kit Cloud (2015-05 ~ 2015-07)

  **Software** AngularJS, Compass, ASP.NET WebApi, NHibernate, NGINX, OWIN
  
  **Description**
  
  The 2020 Design software has amount of customers, used by customer's designers, but there are little communication between the designers, they need a platform to communicate. This is the main goal of building this project, create a platform between designers for share, reuse, or trading.

  At the start of this project, we consider it should be deployed to the cloud, use clusters to avoid single point of failure, and cross platform service mixed.
  
  At client side, we use AngularJS and RequireJS to do model dynamic loading, use SCSS based Compass to pre-process stylesheets, and Bootstrap to achieve responsive layout. 
  
  At server side, we use ASP.NET WebApi to build state-less REST service, runing on OWIN, make it easy to be deployed to cluster.
  
  We use ASP.NET Identity to implement user authentication and authorize, extend support of OAuth2 with OWIN middleware, users can use logon with any public service that supports OAuth2 (Twitter, Facebook, Google, etc), and our customer's private OAuth2 server is supported too.

  As to the deploy, we use the following soluation:
  
  - Use Linux + NGINX to do Reproxy and load balance;
  - The static files of client side (html, js, css, images, kit etc) is deployed to multiple Linux + NGINX servers, use rsync for sync;
  - The REST Service of server side is deployed to multipul Windows + IIS servers, use ADFS for sync;
  - We deployed SQL Server's high available group to do load balance partially, as we know there is no real load balance cluster for SQL Server, but with this project, the data read is more and more then write, so the high available group works;

  **Responsibility**
  
  1. Architect design and prototype implement;
  2. Learn Linux and NGINX;
  4. Guide developers to learn and use Angular and Compass;
  5. Guide developers to use and extend WebApi and OWIN;

- Pollution License Management System (2014-12 ~ 2015-05)
  

  **Software** AngularJS, Compass, ASP.NET WebApi, OWIN, NHibernate
  
  **Description**

  This project is part of the Enterprise Service Platform Of GDEP, it is build for the enterprises of Guangdong province, who can apply, renewal, or cancel their polluation licenses, and for the agency of GDEP, who can manage the licenses.

  This project uses ASP.NET WebApi at the server side to provide RESTful service, which is very easy to use at the client browser side, and uses AngularJS to build Single Page Application (SPA) at the client side to gain a good user experience.
  
  **Responsibility**

  1. Architect design and prototype implement;
  2. Guide developers to use and extend WebApi and OWIN;
  3. Guide developers to learn and use Angular and Compass;
  4. OWIN cache middleware design and implement;
  5. AngularJS perfermance hacking;

- Water Quality Pre-Warning (2014-09 ~ 2014-12)

  **Software** ASP.NET MVC, Silverlight, NHibernate

  **Description**

  Based on the SilverGIS platform, integrate of water pollution model program, show the result with frame animation on map, and integrate of pre-warning interface. 

  **Responsibility**

  1. Guide developers to integrate water pollution model program, including data pre-process, compute and result process.
  2. Guide developers to integrate the water pre-warning interface.
  3. Implementation of showing the result animation;

- Reproxy of Mobile Device  (2014-06 ~ 2015-04)

  **Software** OWIN, WebAPI, Mono， NGINX

  **Description**

  The mobile device of Mobile Enforce project need to access the internal service from public internet, and we do not want make the service public, so we develop the reproxy project.

  This project use Microsoft Open Web Interface for .NET (OWIN), with the useage of middleware asynchronous process model, we implement scalable and high performance reproxy. We also use NGINX for load balance, avoid single point of failure.

  **Reponsibility**

  1. Reproxy architech design and impl;
  2. Performance turning,  make full use of the async process pipe line;

- Environment Protect REST Service standard (2014-04 ~ 2014-06)

  **Software** OWIN, WebAPI

  **Description**

  The business of Environment Protection is implemented by different teams, the service they build is different too, that is not easy to manage. So we develop the stand of the REST service we build, include:

  - Use HTTP 1.1 protocal,  semantics request and response;
  - Descript our service with standard RESTful API Modeling Language (RAML);

  **Responsibility**

  1. REST Service standard design and samples;
  3. Train developers about RAML;
  3. Guide developers to refactor the existing service, adapt the new REST standard;
  4. Guide developers to write test script according to the REST standard;

- OAuth2 Server of GDEP (OAuth2) (2014-02 ~ 2014-03)

  **Software** ASP.NET MVC, Bootstrap, AngularJS

  **Description**

  The SSO of GDEP is using windows active directory authority, the shortcoming is every application need to access AD, this is a threation of the security of AD, so we deside to switch to OAuth2;

  On the service side, we use implement a standard OAuth2 server using standard ASP.NET MVC, active directory as authorize adapter; We use Bootstrap to implement responsive layout, compatible with multi browsers on defferent devices, use AngularJS to implement two way data binding and modular development;

  **Responsibility**

  - Architect design, follow OAuth2 specification， follow ASP.NET MVC standard；
  - Guide developers to implement OAuth2 with ASP.NET MVC;
  - Guide developers to implement responsive layout with Bootstrap;
  - Guide developers to implement manage views with AngularJS;

- EQPub platform update (2013-09 ~ 2013-12)

  **Software** ASP.NET MVC, Silverlight, Mono, Android, iOS

  **Description**

  Major update of Environment Quality Publish Platform, focus on the update of air quality index module (PM2.5), which is of public concern, the information of PM2.5 is update from Pearl River Delta to Guangdong Province, and we also add Two social publishing channels, which is Sina Weibo and Weixin,  client app (Android and iOS) is also under development.

  **Responsibility**

  1. Architecture design of server side and client side;
  2. Research of MvvmCross an open source Mvvm Platform for Xamarin.iOS, Xamarin.Android, WindowsPhone, WindowsStore, WPF and Mac, prepare for subsequent development

- Mobile Law Enforcement System (2012-03 ~ Present)

  **Software** ASP.NET MVC， Silverlight， iOS  

  **Description** 

  Implementation of existing law enforcement systems on iPad, the main feature will be the need for the Central Administration site for paper records by law enforcement officials, forensic work conducted into assisted by mobile devices, streamline the enforcement process also provides client tracing analysis based on GPS to facilitate server-side GIS-based task allocation and monitoring.

  **Responsibility**

  1. Involved in the overall design and requirement analysis;
  2. Client side and Serverside overall design and impl;
  3. Responsible for training outsourcing team about MonoTouch;
  4. Technical support, provide ArcGIS soluation with MonoTouch;
  5. Assist project deployment and acceptance;

- Environmental protection projects approval and tracking (2011-03 ~ 2011-11)

  **Software** Silverlight 5， iOS 5  

  **Description**

  The approval and tracking of Environmental protection related projects, include two main modules:

  1. The approval module was implemented with ArcGIS Silverlight API and ArcGIS Server,  main function is to analyze the environment around the proposed project information, including drinking water reserves, rivers leakages, analysis of built-up area, provide macro-GIS credentials;

  2. The tracking module to facilitate the law enforcement officers out of the Office, implemented on iPad device, build with MonoTouch and iOS, the main function is on the construction project environmental field trips and tracking, as a complement to project approval.

  **Responsibility**  

  1. Learning of ArcGIS related technology, include ArcGIS Silverlight Client API, and ArcGIS Server REST API;
  2. Guidance development work related to other colleagues for ArcGIS; 
  3. Learn iOS related knowledge, Complete mobile development work using MonoTouch;

-  Environmental assurance project for The Asian Games (2010-03 ~ 2010-09)

  **Software** ASP.NET MVC, Silverlight  

  **Description**

  The Asian Games (2010 Guangzhou) related environment quality information integration and publishing, including drinking water water, and air pollution index, and river pollution situation, and Asia Games venues around sources focus monitoring, with the common efforts of entire development department, this project went online just before The Asian Games starts, can show monitoring data of related points, and can show 7 days weather forecast  and air quality information of related cities, do some works during The Asian Games;

  **Responsibility** 

  1. Software archtecture design;
  2. Major technical difficulties attack, such as part of overall, detailed design and implementation of module, switch effect between modules;
  3. Guide the work of other colleagues to complete tasks;
  4. Assist in the testing and deployment of the project;

- Water Analysis System For Pearl River Delta (2008-12 ~ 2015-04)

  **Software** Arc GIS Server 9.3, Silverlight 3.0, SQL Server 2008, ASP.Net 2.0, .Net 3.5

  **Description**

  Our goal is build a Water Environment Analysis System for Pearl River Delta, provide analysis information of hydrodynamic force model and water pollution model, provide aid decision making information. 

  Clientside build on Microsoft Silverlight Platform, serverside based on ESRI ArcGIS Server 9.3, combine with Windows Communication Foundation (WCF), .Net RIA Services, ADO.net DataService, etc.

  **Responsibility**

  1. Participate project's requirement analysis; 
  2. Design the project's architecture; 
  3. Development of the project's core model; 
  4. Key problem attack;

- eGIS of GDEPB (2008-03 ~ 2008-09)

  **Software** ASP.Net 2.0, IIS 6.0, ExtJS 2.0, Virtual Earth 6.5

  **Description**

  The exhibit platform with gis technology for information of environment protection, comes with two pattern, 2D part and 3D part: 

  1. The 2D part is based on Browser/Server(BS) pattern, Combine with Microsoft Virtual Earth and ExtJS in the browser side, it give our user greate user experience. 
  2. The 3D part is based on .Net SmartClient pattern, secondary development of WorldWind, NASA's open source project with Managed DirectX (MDX), a fresh 3D user experience produced.

  **Responsibility**

  1. Participate project's requirement analysis and architecture design;
  2. Training of new co-worker; 
  3. Development of the 3D open up model. 
  4. The 2D model's architecture design and core model implement.

- Poluation Online Monitoring (2007-10 ~ 2013-12)

  **Software** ASP.Net 2.0, ExtJS 1.1, Virtual Earth 6.5, SQL Server 2005

  **Description**

  Online Monitoring Plateform of Pollution Source of GuangDong Province, is is an environmental information center to focus on real-time data monitoring, real-time (history) video surveillance, historical data analysis, a comprehensive platform for supporting decision-making focus on the following modules Composition: 

  1. Data reporting module based on SOA architecture; 
  2. Video surveillance module based on XML-RPC; 
  3. Multidimensional analysis module based on Microsoft Sql Server Data Warehouse; 
  4. Report module based on Microsoft Sql Server Reporting Service; 
  5. WebGIS-based display model build on Microsoft Virtual Earth technology; 
  6. Backstage management module build with ExtJS;

  **Responsibility**

  1. Overall design and requirements analysis; 
  2. Involved in project management, project docs, source code manage; 
  3. Data reporting module; 
  4. Database,warehouse design; 
  5. WebGIS, background manage module

- Portal Website for HuiZhou EPB (2006-06 ~ 2007-09)

  **Software** ASP.Net 2.0, Share Point 3.0, Windows Server 2003, SQL Server 2005

  **Description**

  Portal Website for HuiZhou EPB is a Comprehensive gateway, multiple-service portal, and it was build with Microsoft SharePoint 3.0, and Microsoft Ajax library 1.0.

  **Responsibility**

  1. Webpart and SitePage development;
  2. SharePoint page custom design;
  3. Single Sign On (SSO) with other business systems;

- The 11th Five-Year National City Assess System (2005-12 ~ 2006-05)

  **Software** ASP.Net2.0, WindowsServer2003, IIS6.0, DotNetNuke 4.0, SQL Server 2005

  **Description**

  The National 11th Five-year CityAssess System, Serverside is based on the DotNetNuke (DNN) plateform, and the clientside is based on Microsoft Ajax Library (codename atlas), mainly including data management, Excel data import and export, report management, user rights management of several large modules, each module details are as follows:

  1. Data management module based on the DNN module development and integration with Microsoft Ajax client library implementation; 
  2. Excel import and export by calling the third-party Excel reading and writing components (ExcelIO) implementation; 
  3. Report Management System for self-development; 
  4. User rights module based on the original DNN user management module to do secondary development to achieve.

  **Responsibility**

  1. DNN module and Microsoft Ajax library integration;
  2. Development of the core data management module;
  3. Excel import and export module;
  4. Report design and implementation;
  5. User rights management module;

- WWW of Guangdong Environmental Protection (2005-10 ~ Present)

  **Software** ASP.Net 2.0, Windows Server 2003, IIS 6.0, SQL Server 2000

  **Description**

  GuangDong Environmental Protection Public Website, one of the three major website of GuangDong Environmental Protection Office, is a public-priented website, and the public about environmental information window. 

  The main building blocks of the site has a public information release module, full-text search module, e-mail subscription module, the regional environmental quality publication module and other modules that constitute a small, detailed information of each module are as follows:

  1. The public information dissemination module TRS-based content management system as a secondary development; 
  2. Lucene.net based on full-text search module development; 
  3. E-mail subscription module TRS-based content information system as a secondary development; 
  4. Regional environmental quality publication module based on open-source RIA frameworks (ExtJS) and Microsoft's mapping service (Virtual Earth) development. 

  **Responsibility**

  1. Full-text search module design and implementation with Lucene.net;
  2. Email subscription module design and implementation based on TRS;
  3. Regional environmental quality release module design and implementation based on ExtJS and Micrsoft Virtual Earth;

- Intra website of GDEPB (2005-9 -- 2005-11)

  **Software** ASP.Net 2.0, IIS 6.0, SQL Server 2005,  
  
  **Description**

  One of the three main website of GDEPB, only open for employees of GDEPB, Provide intranet information exchange, including news publish, instant messaging,  contact list and forum, information of each module as follow:

  1. News publish module was something like microsoft's PetShop;
  2. Data access layer was build with Apache's iBatis.Net;
  3. Instant messaging was based on iOffice;
  4. Cantact list was integraged with Microsoft's Active Directory;
  5. Froum was based on DotNetNuke (DNN);

  **Responsibility**

  1. Design and impl of news publish module;
  2. Integration of instant messaging module;
  3. Design and impl of cantact list module;
  4. Secondary development of DNN's forum module;

### Open source

- [Xamarin binding of PNChart for iOS](https://github.com/beginor/PNChartTouch): 

  The [PNChart for iOS](https://github.com/kevinzhow/PNChart) is very famous, easy to use, with cool animcation effects, I create this binding project for using with Xamarin.iOS.

- [Xamarin binding of ArcGIS for Android](https://github.com/beginor/MonoDroid.ArcGIS):

  Xamarin binding of [ArcGIS](http://www.arcgis.com/) for Android ， almost all features can be used, incuding GraphicsLayer, FeatureLayer, Symbol, DynamicLayer etc.

- [Assembly Navigation for Silverlight 5](https://github.com/beginor/AssemblyNavigation) :

  Navigation and loading framework for silverlight, my original works, loads dll assemblies on demand from server, can definitely decrease the initial load time of silverlight application, the more modules of your projects, the effect is more.

### Technical articles:

- [Async task queue for Silverlight](http://www.cnblogs.com/beginor/archive/2010/12/24/1915910.html)
- [The limits of MonoTouch](http://www.cnblogs.com/beginor/archive/2011/09/24/2189767.html)
- [Summary of development with ExtJS](http://www.cnblogs.com/beginor/archive/2008/12/14/1354922.html)
- [Good habits of senior programer](http://beginor.github.io/2013/04/08/senior-programer-good-habits.html)
- [Ten tips for C# programer](http://beginor.github.io/2014/08/01/top-10-tips-for-c-programmers.html) 
- [Comparison of acchitecture presentation patterns](http://beginor.github.io/2012/10/17/Comparison-of-Architecture-presentation-patterns.html)

### Education

- 2001-09 ~ 2005-07	South China Normal University Physics Bachelor

### Language Skills

- CET 6, Good at Listening/Speaking，Reading Writing;

# Reading list

- Algorithms 4th edition

  Some of my work is about mobile app develop, the performance of mobile device is poor compare with PC or server, so the Algorithms is very importand, and I choose this book to review algorithms.

  The book has excellent visualization about algotighms, for each algorithms, there is animation, explain the algorighms step by step, make it very easy to understand. After reading this book, I have a more clear understanding about sort and search algorithms.

- 97 Things Every Software Architect Should Know
  
  This book provides a new way to share atchitect knowledge, summarize over fifty top software architector's years of experience, include their professional ethics, skills, thinking patterns, leadership, communications with customers, the balance of think about the gains and losses etc.

  The option which has most effect to me are "If you design it, you should be able to code it" and "Architects focus is on the boundaries and interfaces", I will be more aware of how to use the API I defined, and be more aware of communication between modules.

- .Net essentials

  This book is about .NET fundations and deepin analysis, research the .NET CLR, include the IL and GC;

- Clean Code

  This book use lots of examples to explain how to keep your code cleaning, After reading this book, I have learned:

  - The defference between good code and bad code;
  - How to write good code, and how to refact the bad code;
  - How to write good name, function, object and class;
  - How to format code to keep it readable;
  - How to handle exception without change to exist logic;
  - How to use unit test and test driven development;

  There are three part about this book, refactor, unit test and code format. I develop code standards for my team, enhance unit test, and also be aware of refactoring after reading the book;

- Programming WPF

  This book explains every thing in detail about XAML/WPF, including dependency property, data binding, styles, template, navigation, resource, animation, graphics and multimedia etc.

  This book helps me a lot when developing Silverlight applications;

- Learning ExtJS

   This book explains the core concept, component and layout, managed rendering model, data bind, common control and chart of ExtJS. After reading this book, I can master ExtJS in projects.

- Refactor - Improve your existing code

   This book use easy understood languate, lot of refactor samples to explain the smell of bad code, and how to refact them, give me some help on improving my code.

- Design Patterns Explained

   This book explains the basics about design patterns, and the importance of object oriented analysis and design, and then use simple code to explain the twelve design patterns frequently used, include the basics, advantage and disadvantage, implementation, let readers know the principal and motive of design patterns, and understand how design pattern works.

   This is the first book I read about design patterns, it is a bible for me. After reading this book, I understand the basics of design patterns, and start to be aware of interface programming.

## reference keywords

`web` `uml` `html` `css` `soa` `nhibernate` `ios` `android` `mvc` `oop` `json` `angularjs` `compass` `scss`

---

# Thanks

Thanks for reading my resume, hoping working with you.