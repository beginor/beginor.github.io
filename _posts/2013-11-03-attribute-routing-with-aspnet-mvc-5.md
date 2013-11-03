---
layout: post
title: Attribute Routing With ASP.net MVC 5
description: Attribute Routing With ASP.net MVC 5
tags: [转载, MVC]
keywords: asp.net-mvc5, attribute, routing
---

## Introduction

- This Article shows how to use the Latest **ASP.net MVC 5 Attribute Routing** with your Application.
- This Article has 2 parts.First part of this Article will show the basic usage of **Attribute Routing**.
- The Second part of this Article will show some advance usage of Attribute Routing.

## What is Routing ?

Routing is how ASP.net MVC matches a URI to an Action

## What is Attribute Routing ?

- **ASP.net MVC 5** supports a new type of Routing, called **Attribute Routing**
- As the name implies, attribute routing uses **attributes to define routes**
- Attribute routing gives you more control over the URIs in your web application

## How To Enable Attribute Routing ?

- For that, You have to select the `RouteConfig.cs` inside the `App_Start` Folder.
- After that call `MapMvcAttributeRoutes` is as below.

RouteConfig.cs

    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapMvcAttributeRoutes();//Attribute Routing

            //Convention-based Routing
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index",
                                id = UrlParameter.Optional }
            );
        }
    }

Key points of the above code

- To enable Attribute Routing,You have to call MapMvcAttributeRoutes on RouteConfig File.
- If you want, You can keep the Convention-based Routing also with the same file is as above.
- But routes.MapMvcAttributeRoutes(); Should configure before the Convention-based Routing.

## How to use Optional URI Parameters ?

- To that you can add a question mark to the Route parameter
- Well, It's like this : `[Route("Pet/{petKey?}")]`

PetController.cs

    public class PetController : Controller
    {
        // eg: /Pet
        // eg: /Pet/123
        [Route("Pet/{petKey?}")]
        public ActionResult GetPet(string petKey)
        {
            return View();
        }
    }

Key point of the above code

- In the above example, both `/Pet` and `/Pet/123` will Route to the `GetPet` Action

Above Route on Browser is as below

![](/assets/post-images/AR3.png)

## How to use Default Values URI Parameters ?

- To that you can specify a default value  to the route parameter
- It's like this : `[Route("Pet/Breed/{petKey=123}")]`

PetController.cs

    public class PetController : Controller
    {
        // eg: /Pet/Breed
        // eg: /Pet/Breed/528
        [Route("Pet/Breed/{petKey=123}")]
        public ActionResult GetSpecificPet(string petKey)
        {
            return View();
        }
    }

Key point of the above code

- In the above example, both `/Pet/Breed` and `/Pet/Breed/528` will route to the `GetSpecificPet` Action

Above Route on Browser is as below

![](/assets/post-images/AR4.png)

## How to use Route Prefixes ?

- Normally, the routes in a controller all start with the same prefix
- Well,It's like this : /Booking

BookingController.cs

    public class BookingController : Controller
    {
        // eg: /Booking
        [Route("Booking")]
        public ActionResult Index() { return View(); }

        // eg: /Booking/5
        [Route("Booking/{bookId}")]
        public ActionResult Show(int bookId) { return View(); }

        // eg: /Booking/5/Edit
        [Route("Booking/{bookId}/Edit")]
        public ActionResult Edit(int bookId) { return View(); }
    }

Above Routes on Browser are as below

![](/assets/post-images/AR5.png)

## How to Set Common Route Prefix ?

- If you want, you can specify a common prefix for an entire controller
- To that you can use `[RoutePrefix]` attribute
- It's like this : `[RoutePrefix("Booking")]`

BookingController.cs

    [RoutePrefix("Booking")]
    public class BookingController : Controller
    {

        // eg: /Booking
        [Route]
        public ActionResult Index() { return View(); }

        // eg: /Booking/5
        [Route("{bookId}")]
        public ActionResult Show(int bookId) { return View(); }

        // eg: /Booking/5/Edit
        [Route("{bookId}/Edit")]
        public ActionResult Edit(int bookId) { return View(); }

    }

Above Routes on Browser are as below

![](/assets/post-images/AR5.png)

## How to Override the Common Route Prefix ?

- You can use a tilde (~) on the method attribute to override the route prefix
- Well,It's like this : `[Route("~/PetBooking")]`

BookingController.cs

    [RoutePrefix("Booking")]
    public class BookingController : Controller
    {
        // eg: /PetBooking
        [Route("~/PetBooking")]
        public ActionResult PetBooking() { return View(); }
    }

Above Route on Browser is as below



## How to use Default Route ?

- You can apply the `[Route]` attribute on the Controller level and put the Action as a parameter
- That Route will then be applied on all Actions in the Controller
- Well,It's like this : `[Route("{action=index}")]`

BookingController.cs

    [RoutePrefix("Booking")]
    [Route("{action=index}")]
    public class BookingController : Controller
    {
        // eg: /Booking
        public ActionResult Index() { return View(); }

        // eg: /Booking/Show
        public ActionResult Show() { return View(); }

        // eg: /Booking/New
        public ActionResult New() { return View(); }

    }

Above Routes on Browser are as below

![](/assets/post-images/AR7.png)

## How to override Default Route ?

- For that you have to use specific `[Route]` on a specific Action.
- It'll override the default settings on the Controller.

BookingController.cs

    [RoutePrefix("Booking")]
    [Route("{action=index}")]
    public class BookingController : Controller
    {
        // eg: /Booking
        public ActionResult Index() { return View(); }

        // eg: /Booking/Edit/3
        [Route("Edit/{bookId:int}")]
        public ActionResult Edit(int bookId) { return View(); }

    }

Above overridden Route on Browser is as below

![](/assets/post-images/AR8.png)

## How to give Route Names ?

- You can specify a Name for a Route
- By using that Name, you can easily allow URI generation for it
- Well,It's like this : `[Route("Booking", Name = "Payments")]`

BookingController.cs

    public class BookingController : Controller
    {
        // eg: /Booking
        [Route("Booking", Name = "Payments")]
        public ActionResult Payments() { return View(); }
    }

- After that you can generate a Link is using Url.RouteUrl
- It's like this : `<a href="@Url.RouteUrl("Payments")">Payments Screen</a>`

Note : On the above code, "Payments" is a Route Name

Advantages of Attribute Routing Over the Convention-based Routing

- Attribute Routing gives you more control over the URIs in your web application
- Easy to Troubleshoot issues
- No fear of modifying anything will break another route down the line 

## Conclusion

- You saw that how easily can configure the URI Routines with Attribute Routing
- In my next article I will show how to apply Attribute Routing with Route Constraints, Custom Route Constraints and Areas
- So enjoy this Awesome New Feature of ASP.net MVC 5


http://sampathloku.blogspot.com/2013/11/attribute-routing-with-aspnet-mvc-5.html