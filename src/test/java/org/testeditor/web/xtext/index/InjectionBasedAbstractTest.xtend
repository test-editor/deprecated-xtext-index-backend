package org.testeditor.web.xtext.index

import org.junit.Before
import com.google.inject.Guice

abstract class InjectionBasedAbstractTest {
	@Before
	def void setupInjection() {
		Guice.createInjector.injectMembers(this)
	}
}