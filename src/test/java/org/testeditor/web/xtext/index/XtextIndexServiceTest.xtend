package org.testeditor.web.xtext.index

import com.google.inject.Injector
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.XtextStandaloneSetup
import org.eclipse.xtext.mwe.ResourceDescriptionsProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.Before
import org.junit.Test

import static org.assertj.core.api.Assertions.assertThat
import org.eclipse.xtext.XtextPackage
import com.google.inject.Key
import com.google.inject.name.Named
import org.eclipse.xtext.Constants
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.util.EcoreUtil

class XtextIndexServiceTest {

	var Injector injector

	@Before
	def void metamodelMustBeKnown() {
		injector = new XtextStandaloneSetup().createInjectorAndDoEMFRegistration
	}

	@Test
	def void shouldLoadResourceIntoIndex() {
		// given
		val resourceSet = injector.getInstance(XtextResourceSet)
		resourceSet.getResource(URI.createFileURI("src/test/resources/index/MyDsl.xtext"), true)
		val expectedName = QualifiedName.create("org", "xtext", "example", "mydsl", "MyDsl")

		// when
		val index = injector.getInstance(ResourceDescriptionsProvider).get(resourceSet)

		// then
		assertThat(index.exportedObjects.head.name).isEqualTo(expectedName)

	}

	@Test
	def void shouldReturnEPackageByName() {
		// given
		val ePackage = EPackage.Registry.INSTANCE.getEPackage("http://www.eclipse.org/2008/Xtext")
		val expectedEReference = XtextPackage.eINSTANCE.grammar_UsedGrammars
		
		// when
		val grammar = ePackage.getEClassifier("Grammar")
		
		// then
		assertThat(grammar.eCrossReferences).contains(expectedEReference)
	}
	
	@Test
	def void shouldBeReconstructibleFromURI() {
		// given
		val eReferenceURI = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars)
		
		// when
		val ePackage = EPackage.Registry.INSTANCE.getEPackage(eReferenceURI.trimFragment().toString())
		val actualEObject = ePackage.eResource.getEObject(eReferenceURI.fragment)
		
		
		// then
		assertThat(actualEObject).isInstanceOf(EReference)
		assertThat((actualEObject as EReference).name).isEqualTo("usedGrammars")
		assertThat(actualEObject).isSameAs(XtextPackage.eINSTANCE.grammar_UsedGrammars)
	}
}
