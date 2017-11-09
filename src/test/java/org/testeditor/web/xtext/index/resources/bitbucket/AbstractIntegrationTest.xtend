package org.testeditor.web.xtext.index.resources.bitbucket

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import io.dropwizard.testing.ResourceHelpers
import io.dropwizard.testing.junit.DropwizardAppRule
import java.io.File
import javax.ws.rs.client.Invocation
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.junit.After
import org.junit.ClassRule
import org.junit.Rule
import org.junit.rules.TemporaryFolder
import org.testeditor.tsl.dsl.web.TslWebSetup
import org.testeditor.web.xtext.index.XtextIndex
import org.testeditor.web.xtext.index.XtextIndexApplication

import static io.dropwizard.testing.ConfigOverride.config
import org.testeditor.tcl.dsl.TclStandaloneSetup
import org.testeditor.aml.dsl.AmlStandaloneSetup

class AbstractIntegrationTest {

	public static class TestXtextIndexApplication extends XtextIndexApplication {
		val tslWebSetup = new TslWebSetup
		val injector = tslWebSetup.createInjector

		override getLanguageSetups() {
			return #[tslWebSetup, new TclStandaloneSetup, new AmlStandaloneSetup]
		}

		override getIndexInstance() {
			return injector.getInstance(XtextIndex) // construct index with language injector
		}

		override protected getGlobalScopeProvider() {
			return injector.getInstance(IGlobalScopeProvider)
		}

	}

	@ClassRule
	public static val temporaryFolder = new TemporaryFolder

	@Rule
	public val dropwizardRule = new DropwizardAppRule(TestXtextIndexApplication,
		ResourceHelpers.resourceFilePath("config.yml"), #[
			config('repoLocation', temporaryFolder.root.absolutePath)
		])

	@After
	public def void cleanupTempFolder() {
		// since temporary folder is a class rule (to make sure it is run before the dropwizard rul),
		// cleanup all contents of the temp folder without deleting it itself
		recursiveDelete(temporaryFolder.root, false)
	}

	protected def String getToken() {
		val builder = JWT.create => [
			withClaim('id', 'john.doe')
			withClaim('name', 'John Doe')
			withClaim('email', 'john@example.org')
		]
		return builder.sign(Algorithm.HMAC256("secret"))
	}

	protected def Invocation.Builder authHeader(Invocation.Builder builder) {
		builder.header('Authorization', '''Bearer «token»''')
		return builder
	}

	protected def void recursiveDelete(File file, boolean deleteThis) {
		file.listFiles?.forEach[recursiveDelete(true)]
		if(deleteThis) {
			file.delete
		}
	}
}
