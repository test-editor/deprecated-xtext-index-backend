/*******************************************************************************
 * Copyright (c) 2012 - 2017 Signal Iduna Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Signal Iduna Corporation - initial API and implementation
 * akquinet AG
 * itemis AG
 *******************************************************************************/

package org.testeditor.web.xtext.index.resources.bitbucket

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import io.dropwizard.testing.ResourceHelpers
import io.dropwizard.testing.junit.DropwizardAppRule
import java.io.File
import javax.ws.rs.client.Entity
import javax.ws.rs.client.Invocation
import org.junit.After
import org.junit.ClassRule
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.testeditor.tsl.dsl.web.TslWebSetup
import org.testeditor.web.xtext.index.XtextIndexApplication

import static io.dropwizard.testing.ConfigOverride.config
import static javax.ws.rs.core.Response.Status.BAD_REQUEST
import static javax.ws.rs.core.Response.Status.NO_CONTENT
import static org.assertj.core.api.Assertions.assertThat

class BitbucketWebhookIntegrationTest {

	public static class TestXtextIndexApplication extends XtextIndexApplication {

		override getLanguageSetups() {
			return #[]
		}

		override getGuiceInjector() {
			return new TslWebSetup().createInjector // construct index with language injector
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

	@Test
	def void pushWebhookReturnsNoContent() {
		// given
		val client = dropwizardRule.client

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/webhook/bitbucket/push''') //
		.request //
		.authHeader //
		.post(Entity.json('''{ "actor" : { "username": "xyz" }, "repository": { }, "push": { } }'''))

		// then
		assertThat(response.status).isEqualTo(NO_CONTENT.statusCode)
	}

	@Test
	def void pushWebhookReturnsErrorOnInvalidJson() {
		// given
		val client = dropwizardRule.client

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/webhook/bitbucket/push''') //
		.request //
		.authHeader //
		.post(Entity.json('''{ "actor" : '''))

		// then
		assertThat(response.status).isEqualTo(BAD_REQUEST.statusCode)
	}

	@Test
	def void pushWebhookReturnsErrorOnInvalidJsonPayload() {
		// given
		val client = dropwizardRule.client

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/webhook/bitbucket/push''') //
		.request //
		.authHeader //
		.post(Entity.json('''{ "actor" : "some" }''')) // incomplete, actor should be an object holding username etc.
		// then
		assertThat(response.status).isEqualTo(BAD_REQUEST.statusCode)
	}

	private def String getToken() {
		val builder = JWT.create => [
			withClaim('id', 'john.doe')
			withClaim('name', 'John Doe')
			withClaim('email', 'john@example.org')
		]
		return builder.sign(Algorithm.HMAC256("secret"))
	}

	private def Invocation.Builder authHeader(Invocation.Builder builder) {
		builder.header('Authorization', '''Bearer «token»''')
		return builder
	}

	private def void recursiveDelete(File file, boolean deleteThis) {
		file.listFiles?.forEach[recursiveDelete(true)]
		if (deleteThis) {
			file.delete
		}
	}

}
