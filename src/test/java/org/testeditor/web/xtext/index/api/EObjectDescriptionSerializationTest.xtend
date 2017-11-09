package org.testeditor.web.xtext.index.api

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.module.SimpleModule
import io.dropwizard.jackson.Jackson
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextFactory
import org.eclipse.xtext.XtextPackage
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.junit.BeforeClass
import org.junit.Test
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

import static org.assertj.core.api.Assertions.assertThat

import static extension io.dropwizard.testing.FixtureHelpers.*
import javax.ws.rs.core.GenericType
import com.fasterxml.jackson.core.type.TypeReference
import java.util.List

class EObjectDescriptionSerializationTest {
	static extension ObjectMapper mapper = Jackson.newObjectMapper

	@BeforeClass
	static def void ensureTestAssumptions() {
		registerSerializers()
		makeXtextModelKnown()
	}

	def static registerSerializers() {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer())
		customSerializerModule.addDeserializer(IEObjectDescription,
			new EObjectDescriptionDeserializer())
		mapper.registerModule(customSerializerModule)
	}

	def static makeXtextModelKnown() {
		EPackage.Registry.INSTANCE.put(XtextPackage.eNS_URI, XtextPackage.eINSTANCE)
	}

	@Test
	def void shouldSerializeToJSON() throws Exception {
		// given
		val sampleEObject = XtextFactory.eINSTANCE.createGrammar
		val description = EObjectDescription.create("sampleEObject", sampleEObject)

		val expected = '''
		{
		  "eObjectURI" : "«description.EObjectURI»",
		  "uri" : "«EcoreUtil.getURI(description.EClass)»",
		  "fullyQualifiedName" : "«description.qualifiedName.toString»"
		}'''

		// when
		val actual = description.writeValueAsString

		// then
		assertThat(actual).isEqualTo(expected)
	}

	@Test
	def void shouldDeserializeFromJSON() throws Exception {
		// given
		val sampleEObjectDescription = "fixtures/eObjectDescription.json".fixture
		val sampleEObject = XtextFactory.eINSTANCE.createGrammar
		val expected = EObjectDescription.create("sampleEObject", sampleEObject)

		// when
		val actual = sampleEObjectDescription.readValue(IEObjectDescription)

		// then
		assertThat(actual).satisfies [
			assertThat(EObjectURI).isEqualTo(expected.EObjectURI)
			assertThat(EClass).isEqualTo(expected.EClass)
			assertThat(qualifiedName).isEqualTo(expected.qualifiedName)
		]
	}
	
		@Test
	def void shouldSerializeListToJSON() throws Exception {
		// given
		val sampleEObject = XtextFactory.eINSTANCE.createGrammar
		val descriptions = #[EObjectDescription.create("sampleEObject", sampleEObject)]

		val expected = '''
		[ {
		  "eObjectURI" : "«descriptions.get(0).EObjectURI»",
		  "uri" : "«EcoreUtil.getURI(descriptions.get(0).EClass)»",
		  "fullyQualifiedName" : "«descriptions.get(0).qualifiedName.toString»"
		} ]'''

		// when
		val actual = descriptions.writeValueAsString

		// then
		assertThat(actual).isEqualTo(expected)
	}
	
	@Test
	def void shouldDeserializeListFromJSON() throws Exception {
		// given
		val sampleEObjectDescription = "fixtures/eObjectDescriptionList.json".fixture
		val sampleEObject = XtextFactory.eINSTANCE.createGrammar
		val expected = EObjectDescription.create("sampleEObject", sampleEObject)

		// when
		val actual = sampleEObjectDescription.<List<IEObjectDescription>>readValue(new TypeReference<List<IEObjectDescription>>(){})

		// then
		assertThat(actual.head).satisfies [
			assertThat(EObjectURI).isEqualTo(expected.EObjectURI)
			assertThat(EClass).isEqualTo(expected.EClass)
			assertThat(qualifiedName).isEqualTo(expected.qualifiedName)
		]
	}

}
