package org.testeditor.web.xtext.index.resources.bitbucket

import javax.ws.rs.client.Entity
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextPackage
import org.junit.Test

import static javax.ws.rs.core.Response.Status.OK
import static org.assertj.core.api.Assertions.assertThat

class GlobalScopeResourceIntegrationTest extends AbstractIntegrationTest {

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
