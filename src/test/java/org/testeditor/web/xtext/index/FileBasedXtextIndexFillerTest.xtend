package org.testeditor.web.xtext.index

import java.io.File
import javax.inject.Inject
import org.junit.Test
import org.testeditor.tcl.dsl.TclStandaloneSetup

import static org.assertj.core.api.Assertions.assertThat

class FileBasedXtextIndexFillerTest extends InjectionBasedAbstractTest {

	@Inject
	var FileBasedXtextIndexFiller indexFiller // class under test

	@Test
	def void testRegisteredLanguagesAreRelevant() {
		// given
		new TclStandaloneSetup().createInjectorAndDoEMFRegistration

		// when
		val allAccepted = #['one.tcl', 'two.tcl', 'one.config', 'one.tml'] //
		.fold(true, [ bool, filename |
			bool && indexFiller.isIndexRelevant(new File(filename))
		])

		// then
		assertThat(allAccepted).isTrue
	}

	@Test
	def void testIrrelevant() {
		// given
		new TclStandaloneSetup().createInjectorAndDoEMFRegistration

		// when
		val allRejected = #['one.xtcl', 'two.txl', 'one', 'Jenkinsfile', 'some.java', 'other.xtend'] //
		.fold(true, [ bool, filename |
			bool && !indexFiller.isIndexRelevant(new File(filename))
		])

		// then
		assertThat(allRejected).isTrue
	}
}