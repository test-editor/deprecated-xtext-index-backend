package org.testeditor.web.xtext.index.resources

import com.fasterxml.jackson.databind.module.SimpleModule
import io.dropwizard.testing.junit.ResourceTestRule
import java.util.List
import javax.ws.rs.Path
import javax.ws.rs.client.Entity
import javax.ws.rs.core.GenericType
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextFactory
import org.eclipse.xtext.XtextPackage
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.junit.Before
import org.junit.ClassRule
import org.junit.Test
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionSerializer

import static org.assertj.core.api.Assertions.assertThat
import org.eclipse.xtext.naming.QualifiedName
import org.junit.Ignore

/**
 * Tests whether the REST interface can be successfully invoked via REST.
 * 
 * The test uses the Xtext language as illustrative example.
 */
@Ignore
class IGlobalScopeResourceTest {

	private static val resourceUnderTest = new DummyGlobalScopeResource

	@ClassRule public static val resources = ResourceTestRule.builder.addResource(resourceUnderTest).build

	@Before
	def void registerCustomSerializers() {
		val customSerializerModule = new SimpleModule
		customSerializerModule.addSerializer(IEObjectDescription, new EObjectDescriptionSerializer())
		customSerializerModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer())
		resources.objectMapper.registerModule(customSerializerModule)
	}

	@Test
	def void shouldTransmitViaREST() {
		// given
		val context = '''
			grammar org.xtext.example.mydsl.MyDsl with org.eclipse.xtext.common.Terminals
			
			generate myDsl "http://www.xtext.org/example/mydsl/MyDsl"
			
			Model:
				greetings+=Greeting*;
				
			Greeting:
				'Hello' name=ID '!';
		'''

		// "http://www.eclipse.org/2008/Xtext#//Grammar/usedGrammars"
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString

		// when
		val actual = resources.target("/xtext/index/global-scope").queryParam("reference", reference) //
		.request.post(Entity.text(context), new GenericType<List<IEObjectDescription>> {
		})

		// then
		assertThat(actual).size.isEqualTo(1)

		val expectedResponse = EObjectDescription.create(QualifiedName.create("de", "testeditor", "ExampleGrammar"),
			XtextFactory.eINSTANCE.createGrammar)
		assertThat(actual).allSatisfy [
			assertThat(EObjectURI).isEqualTo(expectedResponse.EObjectURI)
			assertThat(EClass).isEqualTo(expectedResponse.EClass)
			assertThat(qualifiedName.toString).isEqualTo(expectedResponse.qualifiedName.toString)
		]
		assertThat(resourceUnderTest.context).isEqualTo(context)
		assertThat(resourceUnderTest.eReferenceURIString).isEqualTo(reference)
	}
}

@Path("/xtext/index/global-scope")
class DummyGlobalScopeResource implements IGlobalScopeResource {
	public String context = null
	public String eReferenceURIString = null

	override getScope(String context, String eReferenceURIString) {
		this.context = context
		this.eReferenceURIString = eReferenceURIString

		val description = EObjectDescription.create(QualifiedName.create("de", "testeditor", "ExampleGrammar"),
			XtextFactory.eINSTANCE.createGrammar)

		return #[description]
	}

}
