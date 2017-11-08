package org.testeditor.web.xtext.index.resources.bitbucket

import javax.ws.rs.client.Entity
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextPackage
import org.junit.Test

import static javax.ws.rs.core.Response.Status.NO_CONTENT
import static javax.ws.rs.core.Response.Status.OK
import static org.assertj.core.api.Assertions.assertThat

class GlobalScopeResourceIntegrationTest extends AbstractIntegrationTest {

	@Test
	def void noResourceNoContentCompletion() {
		// given
		val client = dropwizardRule.client
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val context = '''
			grammar org.xtext.example.mydsl.MyDsl with org.eclipse.xtext.common.Terminals
			
			generate myDsl "http://www.xtext.org/example/mydsl/MyDsl"
			
			Model:
				greetings+=Greeting*;
				
			Greeting:
				'Hello' name=ID '!';
		'''

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/global-scope''') //
		.queryParam("reference", reference).request //
		.authHeader //
		.post(Entity.text(context))

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		
	}
}
