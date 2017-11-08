package org.testeditor.web.xtext.index.resources

import com.fasterxml.jackson.databind.module.SimpleModule
import com.google.common.base.Predicate
import com.google.inject.Injector
import io.dropwizard.testing.junit.ResourceTestRule
import java.util.List
import java.util.Set
import javax.ws.rs.client.ClientBuilder
import javax.ws.rs.client.Entity
import javax.ws.rs.client.WebTarget
import javax.ws.rs.core.GenericType
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.Grammar
import org.eclipse.xtext.XtextFactory
import org.eclipse.xtext.XtextPackage
import org.eclipse.xtext.XtextStandaloneSetup
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.testeditor.web.xtext.index.XtextIndex
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

import static org.assertj.core.api.Assertions.assertThat
import static org.mockito.Mockito.*
import org.junit.After

class GlobalScopeResourceTest {

	var ResourceSetBasedResourceDescriptions mockIndex

	var Injector injector

	@Before
	def void setUp() {
		makeXtextModelKnown
		registerCustomSerializers
		setUpMockIndex(true)
	}

	private def void makeXtextModelKnown() {
		injector = new XtextStandaloneSetup().createInjectorAndDoEMFRegistration
	}

	private def void registerCustomSerializers() {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer())
		customSerializerModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer())
		resources.objectMapper.registerModule(customSerializerModule)
	}

	private def setUpMockIndex(boolean initResourceSet) {
		if(mockIndex === null) {
			mockIndex = new ResourceSetBasedResourceDescriptions
		}
		if(initResourceSet) {
			val resourceSet = new XtextResourceSet
			resourceSet.getResource(URI.createFileURI("src/test/resources/index/MyDsl.xtext"), true)
			mockIndex.context = resourceSet
		}

		return mockIndex
	}

	@After
	def void tearDown() {
		mockIndex = null
		injector = null
	}

	@Rule public val resources = ResourceTestRule.builder.addResource(
		new GlobalScopeResource(new MockGlobalScopeProvider, setUpMockIndex(false))).build

	@Test
	def void shouldReturnEmptyDescriptionList() {
		// given
		val String contextResourceURI = null
		val String referenceName = null

		// when
		val actual = resources.target("/xtext/index/global-scope").queryParam("context", contextResourceURI).queryParam(
			"reference", referenceName).request.get(Set)

		// then
		assertThat(actual).isEqualTo(emptySet)
	}

	@Test
	def void shouldReturnObjectDescriptionsInScope() {
		// given
		val context = null
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val expected = EObjectDescription.create("de.testeditor.TestGrammar", XtextFactory.eINSTANCE.createGrammar)
		val globalScopeResource = new GlobalScopeResource(new MockGlobalScopeProvider, mockIndex)

		// when
		val actual = globalScopeResource.getScope(context, reference)

		// then
		assertThat(actual).size.isEqualTo(1)
		assertThat(actual).allSatisfy [
			assertThat(EObjectURI).isEqualTo(expected.EObjectURI)
			assertThat(EClass).isEqualTo(expected.EClass)
			assertThat(qualifiedName).isEqualTo(expected.qualifiedName)
			assertThat(EObjectOrProxy).isNotNull
		]
	}

	@Test
	def void shouldReturnObjectDescriptionsInScopeWhenIvokedViaREST() {
		// given
		val context = ""
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val expected = EObjectDescription.create("sampleEObject", XtextFactory.eINSTANCE.createGrammar)

		// when
		val actual = resources.target("/xtext/index/global-scope").queryParam("reference", reference).request.post(
			Entity.text(context), new GenericType<List<IEObjectDescription>> {
			})

		// then
		assertThat(actual).allSatisfy [
			assertThat(EObjectURI).isEqualTo(expected.EObjectURI)
			assertThat(EClass).isEqualTo(expected.EClass)
			assertThat(qualifiedName).isEqualTo(expected.qualifiedName)
			assertThat(EObjectOrProxy).isNotNull
		]
	}

	@Test
	def void shouldResolveReference() {
		// given
		val globalScopeResource = new GlobalScopeResource(new MockGlobalScopeProvider, mockIndex)
		val eReferenceURI = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString

		// when
		val actual = globalScopeResource.getScope("", eReferenceURI)

		// then
		val expected = EObjectDescription.create("TestGrammar", XtextFactory.eINSTANCE.createGrammar)

		assertThat(actual).size.isEqualTo(1)
		assertThat(actual.get(0)).satisfies [
			assertThat(EObjectURI).isEqualTo(expected.EObjectURI)
			assertThat(EClass).isEqualTo(expected.EClass)
			assertThat(qualifiedName).isEqualTo(expected.qualifiedName)
			assertThat(EObjectOrProxy).isNotNull
		]
	}

	@Test
	def void shouldResolveReferenceWithinContext() {
		// given
		val mockGlobalScopeProvider = new MockGlobalScopeProvider
		val mockIndex = mock(XtextIndex)
		val resourceSet = new XtextResourceSet
		when(mockIndex.resourceSet).thenReturn(resourceSet)
		val globalScopeResource = new GlobalScopeResource(mockGlobalScopeProvider, mockIndex)
		val eReferenceURI = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val context = '''
			grammar org.xtext.example.mydsl.MyDsl with org.eclipse.xtext.common.Terminals
			
			generate myDsl "http://www.xtext.org/example/mydsl/MyDsl"
			
			Model:
				greetings+=Greeting*;
				
			Greeting:
				'Hello' name=ID '!';
		'''

		// when
		val resourceDescriptions = globalScopeResource.getScope(context, eReferenceURI)

		// then
		val uri = URI.createURI("dummy.xtext")
		assertThat(resourceSet.resources).anySatisfy [
			assertThat(URI).isEqualTo(uri)
		]
		assertThat(resourceSet.allContents).hasAtLeastOneElementOfType(Grammar)

		val expectedDescription = mockGlobalScopeProvider.objectDescription
		assertThat(resourceDescriptions).size.isEqualTo(1)
		assertThat(resourceDescriptions.get(0)).satisfies [
			assertThat(EObjectURI).isEqualTo(expectedDescription.EObjectURI)
			assertThat(EClass).isEqualTo(expectedDescription.EClass)
			assertThat(qualifiedName).isEqualTo(expectedDescription.qualifiedName)
			assertThat(EObjectOrProxy).isNotNull
		]

	}
}

class RemoteGlobalScopeProviderClient implements IGlobalScopeProvider {

	val client = ClientBuilder.newClient
	val WebTarget globalScopeTarget

	new(String indexServiceBaseURL) {
		val indexServiceTarget = client.target(indexServiceBaseURL)
		globalScopeTarget = indexServiceTarget.path("xtext/index/global-scope")
	}

	override getScope(Resource context, EReference reference, Predicate<IEObjectDescription> filter) {
	}

}

class MockGlobalScopeProvider implements IGlobalScopeProvider {
	val Grammar referencableGrammar

	new() {
		referencableGrammar = XtextFactory.eINSTANCE.createGrammar
		referencableGrammar.name = "TestGrammar"
	}

	def getObjectDescription() {
		EObjectDescription.create(referencableGrammar.name, referencableGrammar)
	}

	override getScope(Resource context, EReference reference, Predicate<IEObjectDescription> filter) {
		if(reference === null) {
			return IScope.NULLSCOPE
		} else {

			return Scopes.scopeFor(#[referencableGrammar])
		}
	}
}
