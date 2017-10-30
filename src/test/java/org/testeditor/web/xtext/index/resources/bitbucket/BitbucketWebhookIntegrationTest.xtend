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

import io.dropwizard.testing.ResourceHelpers
import io.dropwizard.testing.junit.DropwizardAppRule
import javax.ws.rs.client.Entity
import org.junit.Rule
import org.junit.Test
import org.testeditor.web.xtext.index.XtextIndexHelloWorldApplication

import static javax.ws.rs.core.Response.Status.NO_CONTENT
import static org.assertj.core.api.Assertions.assertThat

class BitbucketWebhookIntegrationTest {

	@Rule
	public val dropwizardRule = new DropwizardAppRule(XtextIndexHelloWorldApplication,
		ResourceHelpers.resourceFilePath("config.yml"))

	@Test
	def void pushWebhookReturnsNoContent() {
		// given
		val client = dropwizardRule.client

		// when
		val response = client //
		.target('''http://localhost:«dropwizardRule.localPort»/xtext/index/webhook/bitbucket/push''') //
		.request() //
		.post(Entity.json('''{ "actor" : { "username": "xyz" }, "repository": { }, "push": { } }'''))

		// then
		assertThat(response.status).isEqualTo(NO_CONTENT.statusCode)
	}

}
