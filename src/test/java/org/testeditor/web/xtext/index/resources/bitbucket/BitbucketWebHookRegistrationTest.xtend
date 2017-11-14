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

import com.codahale.metrics.health.HealthCheckRegistry
import io.dropwizard.jersey.setup.JerseyEnvironment
import io.dropwizard.setup.Environment
import org.junit.Before
import org.junit.Test
import org.testeditor.web.xtext.index.XtextIndexApplication
import org.testeditor.web.xtext.index.XtextIndexConfiguration

import static org.mockito.ArgumentMatchers.isA
import static org.mockito.Mockito.when

import static extension org.mockito.Mockito.mock
import static extension org.mockito.Mockito.verify

class BitbucketWebHookRegistrationTest {
	val environment = Environment.mock
	val jersey = JerseyEnvironment.mock
	val healthChecks = HealthCheckRegistry.mock
	val application = new XtextIndexApplication
	val config = new XtextIndexConfiguration => [
		repoLocation = './repo/'
		repoUrl = 'https://github.com/test-editor/test-editor-examples.git'
	]

	@Before
	def void setup() {
		when(environment.jersey).thenReturn(jersey)
		when(environment.healthChecks).thenReturn(healthChecks)
	}

	@Test
	def void registersPush() {
		// given
		// when
		application.run(config, environment)

		// then
		jersey.verify.register(isA(Push))
	}
}