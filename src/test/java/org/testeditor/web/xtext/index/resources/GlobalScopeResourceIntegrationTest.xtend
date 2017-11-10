package org.testeditor.web.xtext.index.resources

import com.fasterxml.jackson.core.type.TypeReference
import com.fasterxml.jackson.databind.module.SimpleModule
import java.io.InputStream
import java.util.List
import javax.ws.rs.client.Entity
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextPackage
import org.eclipse.xtext.resource.IEObjectDescription
import org.junit.Test
import org.testeditor.tcl.TclPackage
import org.testeditor.web.xtext.index.serialization.EObjectDescriptionDeserializer

import static javax.ws.rs.core.Response.Status.OK
import static org.assertj.core.api.Assertions.assertThat

class GlobalScopeResourceIntegrationTest extends org.testeditor.web.xtext.index.resources.bitbucket.AbstractIntegrationTest {

	@Test
	def void macroReferencedByTcl() {
		// given
		addFileToIndex(
			"pack/MacroLib.tml",
			'''
				package pack
				
				# MacroLib
				
				## FirstMacro
				
					template = "code"
				
					Component: SomeComponent
					- Some fixture call
			'''
		)

		val context = '''
			package pack
			
			# Context
			
			* Some Teststep
			Macro: 
		'''

		val macroCollectionReference = EcoreUtil.getURI(TclPackage.eINSTANCE.macroTestStepContext_MacroCollection).
			toString
		val client = dropwizardRule.client // new JerseyClientBuilder(dropwizardRule.environment).build("test client")
		val jacksonModule = new SimpleModule
		jacksonModule.addDeserializer(IEObjectDescription, new EObjectDescriptionDeserializer)
		val objectMapper = dropwizardRule.environment.objectMapper.registerModule(jacksonModule)

		// when
		val response = client.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/global-scope''') //
		.queryParam("reference", macroCollectionReference) //
		.queryParam("contentType", 'tcl') //
		.queryParam("contextURI", 'pack/context.tcl') //
		.request.authHeader.post(Entity.text(context))

		val payload = objectMapper.<List<IEObjectDescription>>readValue(response.entity as InputStream,
			new TypeReference<List<IEObjectDescription>>() {
			})

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(1)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib")
		]

	}

	@Test
	def void noResourceNoContentCompletion() {
		// given
		val client = dropwizardRule.client
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = "tsl"
		val contextURI = "example.tsl"
		val context = '''
			package some
			
			# example
			
			* some "value" isa wrong .
			* test .
			* s "value""value""value".
		'''

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/global-scope''') //
		.queryParam("reference", reference) //
		.queryParam("contentType", contentType) //
		.queryParam("contextURI", contextURI) //
		.request //
		.authHeader //
		.post(Entity.text(context))

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
	}
}
