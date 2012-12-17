---
layout: post
title: 谈谈 INotifyPropertyChanged 的实现
description: INotifyPropertyChanged 接口是 WPF/Silverlight 开发中非常重要的接口， 它构成了 ViewModel 的基础， 数据绑定基本上都需要这个接口。 所以， 对它的实现也显得非常重要， 下面接贴出我知道的几种实现方式， 希望能起到抛砖引玉的作用。
tags: [.Net Framework]
---

## 谈谈 INotifyPropertyChanged 的实现

INotifyPropertyChanged 接口是 WPF/Silverlight 开发中非常重要的接口， 它构成了 ViewModel 的基础， 数据绑定基本上都需要这个接口。 所以， 对它的实现也显得非常重要， 下面接贴出我知道的几种实现方式， 希望能起到抛砖引玉的作用。

### 一般的实现方式

这是一种再普通不过的实现方式， 代码如下：

	public class NotifyPropertyChanged : INotifyPropertyChanged {
		
		public event PropertyChangedEventHandler PropertyChanged;

		virtual internal protected void OnPropertyChanged(string propertyName) {
			if (this.PropertyChanged != null) {
				this.PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
			}
		}
	}

这种方式称之为一般的实现方式， 因为它确实是太普通不过了， 而且使用起来也让人感到厌恶， 因为必须指定手工指定属性名称： 

	public class MyViewModel : NotifyPropertyChanged {

		private int _myField;

		public int MyProperty {
			get { return _myField; }
			set {
				_myField = value;
				OnPropertyChanged("MyProperty");
			}
		}
	}

### 表达式实现方式

对 lambda 表达式比较熟悉的同学可以考虑用 lambda 表达式实现属性名称传递， 在 NotifyPropertyChanged 类添加一个这样的方法：

	protected void SetProperty<T>(ref T propField, T value, Expression<Func<T>> expr) {
		var bodyExpr = expr.Body as System.Linq.Expressions.MemberExpression;
		if (bodyExpr == null) {
			throw new ArgumentException("Expression must be a MemberExpression!", "expr");
		}
		var propInfo = bodyExpr.Member as PropertyInfo;
		if (propInfo == null) {
			throw new ArgumentException("Expression must be a PropertyExpression!", "expr");
		}
		var propName = propInfo.Name;
		propField = value;
		this.OnPropertyChanged(propName);
	}

有了这个方法助阵， NotifyPropertyChanged 基类使用起来就令人舒服了很多：

	public class MyViewModel : NotifyPropertyChanged {

		private int _myField;

		public int MyProperty {
			get { return _myField; }
			set {
				base.SetProperty(ref _myField, value, () => this.MyProperty);
				 }
		}
	}

这样一来， 把属性名称用字符串传递改成了用 lambda 表达式传递， 减少了硬编码， 确实方便了不少， 但是还是感觉略微麻烦了一些， 还是要写一个 lambda 表达式来传递属性名称。

### 拦截方式实现

如果对 Castal.DynamicProxy 有印象的话， 可以考虑使用 DynamicProxy 进行拦截实现， 我的实现如下：

	// 1. 先定义一个拦截器， 重写 PostProcess 方法， 当发现是调用以 set_ 开头的方法时，
	//    一般就是设置属性了， 可以在这里触发相应的事件。
	internal class NotifyPropertyChangedInterceptor : StandardInterceptor {

		protected override void PostProceed(IInvocation invocation) {
			base.PostProceed(invocation);
			var methodName = invocation.Method.Name;
			if (methodName.StartsWith("set_")) {
				var propertyName = methodName.Substring(4);
				var target = invocation.Proxy as NotifyPropertyChanged;
				if (target != null) {
					target.OnPropertyChanged(propertyName);
				}
			}
		}
	}

	// 2. 再定义一个帮助类， 提供一个工厂方法创建代理类。
	public static class ViewModelHelper {

		private static readonly ProxyGenerator ProxyGenerator = new ProxyGenerator();
		private static readonly NotifyPropertyChangedInterceptor Interceptor
				= new NotifyPropertyChangedInterceptor();

		public static T CreateProxy<T>(T obj) where T : class, INotifyPropertyChanged {
			return ProxyGenerator.CreateClassProxyWithTarget(obj, Interceptor);
		}
	}

使用起来也是很方便的， 只是创建 ViewModel 对象时必须用帮助类来创建实例， 代码如下：

	public class MyViewModel : NotifyPropertyChanged {

		// 定义属性时不需要任何基类方法， 和普通属性没有什么两样。
		public int MyProperty {
			get; set;
		}
	}
	// 使用时需要这样创建实例：
	var viewModel = ViewModelHelper.CreateProxy<MyViewModel>();
	viewModel.MyProperty = 100;

不过这种实现的缺点就是所有的属性都会触发 PropertyChanged 事件， 而且只能触发一个事件， 而在实际开发中， 偶尔需要设置一个属性， 触发多个 PropertyChanged 事件。

### 未来 .Net 4.5 的实现方式

在即将发布的 .Net 4.5 中， 提供了 CallerMemberNameAttribute 标记， 利用这个属性， 可以将上面提供的 SetProperty 方法进行改造， 这样的实现才是最完美的：

	protected void SetProperty<T>(ref T storage, T value, [CallerMemberName] String propertyName = null) {
		if (object.Equals(storage, value)) return;

		storage = value;
		this.OnPropertyChanged(propertyName);
	}

由于有了 CallerMemberName 标记助阵， 可以说使用起来是非常方便了：

	public class MyViewModel : NotifyPropertyChanged {

		private int _myField;

		public int MyProperty {
			get { return _myField; }
			set {
				base.SetProperty(ref _myField, value);
				 }
		}
	}

这种方法虽然好，不过却只有在 .Net 4.5 中才有， 而且也许永远不会添加到 Silverlight 中。
