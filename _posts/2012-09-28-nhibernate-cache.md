---
layout: post
title: NHibernate 缓存
description: 介绍 NHibernate 支持两种级别的缓存， 即一级缓存以及二级缓存。
tags: [NHibernate, 参考]
---

# NHibernate 缓存

NHibernate 支持两种级别的缓存， 即一级缓存以及二级缓存。

## 一级缓存

一级缓存就是 ISession 缓存， 在 ISession 的生命周期内可用， 多个 ISession 之间不能共享缓存的对象， 通过 ISessionFactory 创建的 ISession 默认支持一级缓存， 不需要特殊的配置。 在 NHibernate 的参考文档中， 对 ISession 的描述如下：

> A single-threaded, short-lived object representing a 
> conversation between the application and the persistent
> store. Wraps an ADO.NET connection. Factory for 
> ITransaction. Holds a mandatory (first-level) cache of 
> persistent objects, used when navigating the object graph 
> or looking up objects by identifier. looking up objects 
> by identifier.

注意最后一句， 明确说明了一级缓存的用途：

* 在对象树种导航、浏览时， 使用一级缓存；
* 根据对象的 id 加载对象；

### 一级缓存测试

一级缓存缓存无需配置， 默认支持， 因此， 在使用 session 查询对象， 如果仅仅是根据 id 加载指定的对象， 需要使用 session 的 Get 或 Load 方法， 这样可以充分利用 session 的一级缓存， 下面是一些测试用例以及输出：

**1、测试一级缓存**

	[Test]
	public void TestSessionLoad() {
		using (var session = this._sessionFactory.OpenSession()) {
			Console.WriteLine("Before Load Category");
			var cat = session.Get<Category>(1);
			Console.WriteLine("{0}, {1}", cat.CategoryID, cat.CategoryName);
			cat = session.Get<Category>(1);
			Console.WriteLine("{0}, {1}", cat.CategoryID, cat.CategoryName);
		}
	}

在上面的测试中， 两次加载同一个实体类， 该测试的输出为：

	First get category 1
	NHibernate: 
	    SELECT
	        category0_.[CategoryID] as column1_0_0_,
	        category0_.[CategoryName] as column2_0_0_,
	        category0_.[Description] as column3_0_0_,
	        category0_.[Picture] as column4_0_0_ 
	    FROM
	        [dbo].[Categories] category0_ 
	    WHERE
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]
	1, Beverages
	second get category 1
	1, Beverages

从输出可以看到， 只有第一次调用 Get 方法加载实体类时， 有 sql 输出， 从数据库取出了数据， 第二次加载则没有 sql 数据， 也就是利用了 session 的一级缓存。

**2、测试 Get 与 Load 方法**

session 提供了 Get 和 Load 两个方法， 这两个方法有什么区别呢？ 我的测试代码如下：

	[Test]
	public void TestSessionGet() {
		using (var session = this._sessionFactory.OpenSession()) {
			Console.WriteLine("Before Get Category");
			var cat = session.Get<Category>(1);
			Console.WriteLine("After Get Category");
		}
	}

对应的输出代码如下：

	Before Get Category
	NHibernate: 
	    SELECT
	        category0_.[CategoryID] as column1_0_0_,
	        category0_.[CategoryName] as column2_0_0_,
	        category0_.[Description] as column3_0_0_,
	        category0_.[Picture] as column4_0_0_ 
	    FROM
	        [dbo].[Categories] category0_ 
	    WHERE
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]
	After Get Category

从输出可以看到， 调用 Get 方法之后， Nh 立刻从数据库加载实例， 接下来看对 Load 方法的测试：

	[Test]
	public void TestSessionLoad() {
		using (var session = this._sessionFactory.OpenSession()) {
			Console.WriteLine("Before Load Category");
			var cat = session.Load<Category>(1);
			Console.WriteLine("After Load Category");
			Console.WriteLine("{0}, {1}", cat.CategoryID, cat.CategoryName);
		}
	}

对应的输出代码为：

	Before Load Category
	After Load Category
	NHibernate: 
	    SELECT
	        category0_.[CategoryID] as column1_0_0_,
	        category0_.[CategoryName] as column2_0_0_,
	        category0_.[Description] as column3_0_0_,
	        category0_.[Picture] as column4_0_0_ 
	    FROM
	        [dbo].[Categories] category0_ 
	    WHERE
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]
	1, Beverages

可以看出， 调用完 Load 方法之后， nh 并没有立即从数据库加载实体， 而是等到读取实体类属性时， 才从数据库加载， 也就是说， Load 方法是延迟加载的。

**测试Query**

根据文档的描述， 用 session 查询对象， 应该是不能利用一级缓存的， 我们来测试一下：

	[Test]
	public void TestSessionLambdaQuery() {
		using (var session = this._sessionFactory.OpenSession()) {
			(from c in session.Query<Category>()
				where c.CategoryID == 1
				select c).First();

			(from c in session.Query<Category>()
				where c.CategoryID == 1
				select c).First();
		}
	}

该测试用例的输出如下：

	NHibernate: 
	    select
	        TOP (1)  category0_.[CategoryID] as column1_0_,
	        category0_.[CategoryName] as column2_0_,
	        category0_.[Description] as column3_0_,
	        category0_.[Picture] as column4_0_ 
	    from
	        [dbo].[Categories] category0_ 
	    where
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]
	NHibernate: 
	    select
	        TOP (1)  category0_.[CategoryID] as column1_0_,
	        category0_.[CategoryName] as column2_0_,
	        category0_.[Description] as column3_0_,
	        category0_.[Picture] as column4_0_ 
	    from
	        [dbo].[Categories] category0_ 
	    where
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]

从输出可以看出， 用 session 查询对象， 确实不能利用一级缓存。

*注意： 如果查询时不想使用一级缓存， 可以 StatelessSession 对象， 和 Session 对象用法一样， 只是该对象没有一级缓存。*

### 一级缓存管理

一级缓存的管理也是很简单的， 可以通过下面的三个方法管理：

* `session.Evict` 从一级缓存中删除指定的实例；
* `session.Clear` 清空一级缓存， 不会保存修改的内容；
* `session.Contains` 检查实例是否存在于一级缓存中。

## 二级缓存

二级缓存是 SessionFactory 级别的缓存， 也就是数据库级别的缓存， 可以被同一个 SessionFactory 创建的所有 session 共享。

### 启用二级缓存

Nh 默认未启用二级缓存， 启用二级缓存需要如下步骤：

1、 在 hibernate.cfg.xml 文件中添加下面三个属性：  
   `<property name="cache.provider_class">NHibernate.Cache.HashtableCacheProvider</property>`  
   `<property name="cache.use_second_level_cache">true</property>`  
   `<property name="cache.use_query_cache">true</property>`

这三个属性的作用是显而易见的， 第一个是指定使用什么二级缓存的实现， 第二个是启用二级缓存， 第三个是为查询启用二级缓存缓存。

NHibernate 的二级缓存是可以扩展的， [NHibernate.ControlLib](http://sourceforge.net/projects/nhcontrib/files/NHibernate.Caches/) 提供了几个实现， 分别适用于不同的场景：

* NHibernate.Caches.MemCache
* NHibernate.Caches.Prevalence
* NHibernate.Caches.SharedCache
* NHibernate.Caches.SysCache
* NHibernate.Caches.SysCache2
* NHibernate.Caches.Velocity

这些实现都是

2、 配置指定的实体类、集合启用二级缓存缓存

在 hibernate.cfg.xml 文件中添加下面的设置：

	<class-cache class="HibernateTest.Models.Category" usage="read-only" include="all"/>

这一句表示对实体类 HibernateTest.Models.Category 启用二级缓存， 在实际项目中， 可以根据需要对多个实体类启用二级缓存。 也可以在实体类的 hbm 映射文件中配置使用二级缓存， 不过在 hibernate.cfg.xml 文件中统一配置是推荐的做法。

### 二级缓存测试

二级缓存的几个测试用例如下：

1、 测试 Get 方法：

	[Test]
	public void TestGetEntity() {
		using (var session = this._sessionFactory.OpenSession()) {
			session.Get<Category>(1);
		}
		using (var session = this._sessionFactory.OpenSession()) {
			session.Get<Category>(1);
		}
	}

对应的输出为：

	NHibernate: 
	    SELECT
	        category0_.[CategoryID] as column1_0_0_,
	        category0_.[CategoryName] as column2_0_0_,
	        category0_.[Description] as column3_0_0_,
	        category0_.[Picture] as column4_0_0_ 
	    FROM
	        [dbo].[Categories] category0_ 
	    WHERE
	        category0_.[CategoryID]=@p0;
	    @p0 = 1 [Type: Int32 (0)]

从测试用例的输出可以看出， 二级缓存时可以在不同的 session 之间共享。

2、 测试 HQL 查询：

	[Test]
	public void TestHqlQuery() {
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.CreateQuery("from Category")
				.SetCacheMode(CacheMode.Normal)
				.SetCacheRegion("AllCategories")
				.SetCacheable(true);
			query.List<Category>();
		}
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.CreateQuery("from Category")
				.SetCacheMode(CacheMode.Normal)
				.SetCacheRegion("AllCategories")
				.SetCacheable(true);
			query.List<Category>();
		}
	}

对应的输出为：

	NHibernate: 
	    select
	        category0_.[CategoryID] as column1_0_,
	        category0_.[CategoryName] as column2_0_,
	        category0_.[Description] as column3_0_,
	        category0_.[Picture] as column4_0_ 
	    from
	        [dbo].[Categories] category0_
3、 测试 Linq 查询：

	[Test]
	public void TestLinqQuery() {
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.Query<Category>()
				.Cacheable()
				.CacheMode(CacheMode.Normal)
				.CacheRegion("AllCategories");
			var result = query.ToList();
		}
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.Query<Category>()
				.Cacheable()
				.CacheMode(CacheMode.Normal)
				.CacheRegion("AllCategories");
			var result = query.ToList();
		}
	}

对应的输出为：

	NHibernate: 
	    select
	        category0_.[CategoryID] as column1_0_,
	        category0_.[CategoryName] as column2_0_,
	        category0_.[Description] as column3_0_,
	        category0_.[Picture] as column4_0_ 
	    from
	        [dbo].[Categories] category0_

4、 测试 QueryOver 查询：

	[Test]
	public void TestQueryOver() {
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.QueryOver<Category>()
				.Cacheable()
				.CacheMode(CacheMode.Normal)
				.CacheRegion("AllCategories");
			query.List();
		}
		using (var session = this._sessionFactory.OpenSession()) {
			var query = session.QueryOver<Category>()
				.Cacheable()
				.CacheMode(CacheMode.Normal)
				.CacheRegion("AllCategories");
			query.List();
		}
	}

对应的输出为：

	NHibernate: 
	    SELECT
	        this_.[CategoryID] as column1_0_0_,
	        this_.[CategoryName] as column2_0_0_,
	        this_.[Description] as column3_0_0_,
	        this_.[Picture] as column4_0_0_ 
	    FROM
	        [dbo].[Categories] this_

### 二级缓存选项

NHibernate 二级有几个配置选项， 他们分别是：

**实体类二级缓存配置选项**

**查询二级缓存配置**
